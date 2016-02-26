/*
Copyright (c) 2012-2014 Massive Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
*/

package minject;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class Macro
{
	static var called = false;

	public static function addMetadata()
	{
		if (!called)
		{
			called = true;
			Context.onGenerate(function(types){
				for (type in types)
				{
					switch (type)
					{
						case TInst(t, params): processInst(t, params);
						default:
					}
				}
			});
		}
		
		return haxe.macro.Context.getBuildFields();
	}

	static function processInst(t:Ref<ClassType>, params:Array<Type>)
	{
		var ref = t.get();

		if (ref.isInterface) ref.meta.add("interface", [], ref.pos);
		if (ref.constructor != null) processField(ref, ref.constructor.get());

		var fields = ref.fields.get();
		for (field in fields) processField(ref, field);
	}

	static function processField(ref:ClassType, field:ClassField)
	{
		if (!field.isPublic) return;

		var meta = field.meta.get();
		var abort = true;
		var inject:MetadataEntry = null;

		for (m in meta)
		{
			var name = m.name;
			if (name == "inject" || name == "post")
			{
				if (name == "inject") inject = m;
				abort = false;
				break;
			}
		}
		
		if (abort) return;
		field.meta.add(":keep", [], Context.currentPos());
		
		switch (field.kind)
		{
			case FVar(_, write):
				switch (field.type)
				{
					case TType(t, _):
						var def = t.get();
						
						while(true)
							switch(def.type)
							{
								case TType(t, _): 
									def = t.get();
								default:
									break;
							}
						
						switch (def.type)
						{
							case TInst(t, params):
								processProperty(ref, field, t.get(), params);
							default:
						}
					case TInst(t, params):
						processProperty(ref, field, t.get(), params);
					
					case TAbstract(t, params):
						processProperty(ref, field, t.get(), params);
					default:
				}
			case FMethod(_):
				switch (field.type)
				{
					case TFun(args, _):
					var types = [];
					for (i in 0...args.length)
					{
						var arg = args[i];
						switch (arg.t)
						{
							case TInst(t, _):
								var type = t.get();
								var pack = type.pack;
								var opt = arg.opt ? "true" : "false";
								pack.push(type.name);
								var typeName = pack.join(".");
								var name = inject.params[i] == null ? "" : inject.params[i].toString();
								if (name == null || name == "") types.push(Context.parse('{type:"' + pack.join(".") + '",opt:' + opt + '}', ref.pos));
								else types.push(Context.parse('{type:"' + pack.join(".") + '",opt:' + opt + ',name:' + name + '}', ref.pos));
							default:
						}
					}

					field.meta.add("args", types, ref.pos);
					
					default:
				}
		}
	}

	static function processProperty(ref:ClassType, field:ClassField, type:BaseType, params)
	{
		var pack = type.pack;
		pack.push(type.name);
		
		var typeName = pack.join(".");

		var metas = type.meta.get();
		for (meta in metas)
		{
			if (meta.name == ":native")
			{
				switch (meta.params[0].expr)
				{
					case EConst(c):
					switch (c)
					{
						case CString(s):
						typeName = s;

						default:
					}

					default:
				}
			}
		}

		field.meta.add("type", [Context.parse('"' + typeName + '"', ref.pos)], ref.pos);
	}
}
#end
