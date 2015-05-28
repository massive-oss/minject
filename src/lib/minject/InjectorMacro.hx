// See the file "LICENSE" for the full license governing this code

package minject;

#if macro
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
using Lambda;

class InjectorMacro
{
	static var keptTypes = new Map<String, Bool>();

	/**
		Called by the injector at macro time to tell the compiler which
		constructors should be kept (as they are mapped in for instantiation
		by the injector with Type.createInstance)
	**/
	public static function keep(expr:Expr)
	{
		switch (Context.typeof(expr))
		{
			case TType(t, _):
				var type = t.get();

				var name = type.name;
				name = name.substring(6, name.length - 1);

				if (keptTypes.exists(name)) return;
				keptTypes.set(name, true);

				var module = Context.getModule(type.module);

				for (moduleType in module) switch (moduleType)
				{
					case TInst(t, _):
						var theClass = t.get();
						var className = theClass.pack.concat([theClass.name]).join('.');
						if (className != name) continue;
						if (theClass.constructor != null)
							theClass.constructor.get().meta.add(':keep', [], Context.currentPos());
					case _:
				}
			case _:
		}
	}

	/**
		Returns a string representing the type for the supplied value

		- if expr is a type (String, foo.Bar) result is full type path
		- anything else is passed to `Injector.getValueType` which will attempt to determine a
		  runtime type name.
	**/
	public static function getExprType(expr:Expr):Expr
	{
		switch (Context.typeof(expr))
		{
			case TType(_, _):
				var expr = expr.toString();
				try
				{
					var type = getType(Context.getType(expr));
					var index = type.indexOf("<");
					var typeWithoutParams = (index>-1) ? type.substr(0, index) : type;
					return macro $v{typeWithoutParams};
				}
				catch (e:Dynamic) {}
			case t = TFun(_,_):
				var type = t.toString();
				return macro $v{type};
			default:
		}
		return macro minject.Injector.getValueType($expr);
	}

	static function getType(type:Type):String
	{
		return followType(type).toString();
	}

	/**
		Follow TType references, but not if they point to TAnonymous
	**/
	static function followType(type:Type):Type
	{
		switch (type)
		{
			case TType(t, params):
				if (Std.string(t) == 'Null')
					return followType(params[0]);
				return switch (t.get().type)
				{
					case TAnonymous(_): type;
					case ref: followType(ref);
				}
			default:
				return type;
		}
	}

	/**
		Do not call this method, it is called by Injector as a build macro.
	**/
	public static function addMetadata():Array<Field>
	{
		Context.onGenerate(processTypes);
		return Context.getBuildFields();
	}

	static function processTypes(types:Array<Type>):Void
	{
		for (type in types) switch (type)
		{
			case TInst(t, _): processInst(t);
			default:
		}
	}

	static function processInst(t:Ref<ClassType>):Void
	{
		var ref = t.get();

		// add meta to interfaces, there's no otherway of telling at runtime!
		if (ref.isInterface) ref.meta.add("interface", [], ref.pos);

		var infos = [];
		var keep = new Map<String, Bool>();

		// process constructor
		if (ref.constructor != null) processField(ref.constructor.get(), infos, keep);

		// process fields
		var fields = ref.fields.get();
		for (field in fields) processField(field, infos, keep);

		// keep additional injectee fields (setters)
		for (field in fields)
			if (keep.exists(field.name))
				field.meta.add(':keep', [], Context.currentPos());

		// sort rtti to ensure post constructors are last and in order
		infos.sort(function (a, b) return a.order - b.order);

		// add rtti to type
		var rtti = infos.map(function (info) return macro $v{info.rtti});
		if (rtti.length > 0) ref.meta.add('rtti', rtti, ref.pos);
	}

	static function processField(field:ClassField, infos:Array<{order:Int, rtti:Array<String>}>, keep:Map<String, Bool>):Void
	{
		if (!field.isPublic) return;

		// find minject metadata
		var meta = field.meta.get();
		var inject = meta.find(function (meta) return meta.name == 'inject');
		var post = meta.find(function (meta) return meta.name == 'post');

		// only process public fields with minject metadata
		if (inject == null && post == null) return;

		// keep injected fields
		field.meta.add(':keep', [], Context.currentPos());

		// extract injection names from metadata
		var names = [];
		if (inject != null)
		{
			names = inject.params;
			field.meta.remove('inject');
		}

		// extract post construct order from metadata
		var order = 0;
		if (post != null)
		{
			order = post.params.length > 0 ? post.params[0].getValue() + 1 : 1;
			field.meta.remove('post');
		}

		var rtti = [field.name];
		infos.push({order:order, rtti:rtti});

		switch (field.kind)
		{
			case FVar(_, _):
				keep.set('set_' + field.name, true);
				rtti.push(getType(field.type));
				if (names.length > 0) rtti.push(names[0].getValue());
				else rtti.push('');
			case FMethod(_):
				switch (field.type)
				{
					case TFun(args, _):
						for (i in 0...args.length)
						{
							var arg = args[i];
							var type = getType(arg.t);

							if (!arg.opt && type == 'Dynamic')
							{
								Context.error('Error in method definition of injectee. Required ' +
									'parameters can\'t have type "Dynamic"', field.pos);
							}

							rtti.push(type);
							rtti.push(names[i] == null ? '' : names[i].getValue());
							rtti.push(arg.opt ? 'o' : '');
						}
					default:
				}
		}
	}
}
#end
