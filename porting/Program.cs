using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using Mono.Cecil;
using Mono.Cecil.Cil;

if (args.Length != 3) throw new ArgumentException("Usage: ShieldOnlyPort <upstream-ShieldOnly.dll> <game-refs-dir> <output-ShieldOnly.dll>");
var dll = Path.GetFullPath(args[0]);
var refs = Path.GetFullPath(args[1]);
Console.WriteLine($"DLL={dll}\nREFS={refs}");
var resolver = new DefaultAssemblyResolver();
resolver.AddSearchDirectory(Path.GetDirectoryName(dll)!);
resolver.AddSearchDirectory(refs);
foreach (var d in Directory.GetDirectories(refs)) resolver.AddSearchDirectory(d);
var rp = new ReaderParameters { AssemblyResolver = resolver, ReadSymbols = false, InMemory = true };
var asm = AssemblyDefinition.ReadAssembly(dll, rp);
Console.WriteLine($"Assembly {asm.Name.FullName}");
Console.WriteLine("References:");
foreach (var r in asm.MainModule.AssemblyReferences) Console.WriteLine("  "+r.FullName);
var unresolved = new HashSet<string>();
var targetSummary = new List<string>();
foreach (var t in AllTypes(asm.MainModule.Types)) {
  foreach (var m in t.Methods) {
    if (!m.HasBody) continue;
    foreach (var ins in m.Body.Instructions) {
      if (ins.Operand is MethodReference mr) {
        try { if (mr.Resolve() == null) unresolved.Add($"METHOD {t.FullName}::{m.Name} -> {mr.FullName} [not found]"); }
        catch (Exception e) { unresolved.Add($"METHOD {t.FullName}::{m.Name} -> {mr.FullName} [{e.GetType().Name}: {e.Message}]"); }
      } else if (ins.Operand is FieldReference fr) {
        try { if (fr.Resolve() == null) unresolved.Add($"FIELD {t.FullName}::{m.Name} -> {fr.FullName} [not found]"); }
        catch (Exception e) { unresolved.Add($"FIELD {t.FullName}::{m.Name} -> {fr.FullName} [{e.GetType().Name}: {e.Message}]"); }
      } else if (ins.Operand is TypeReference tr) {
        try { if (tr.Resolve() == null && tr is not GenericParameter) unresolved.Add($"TYPE {t.FullName}::{m.Name} -> {tr.FullName} [not found]"); }
        catch (Exception e) { unresolved.Add($"TYPE {t.FullName}::{m.Name} -> {tr.FullName} [{e.GetType().Name}: {e.Message}]"); }
      }
    }
  }
  foreach (var ca in t.CustomAttributes) {
    if (ca.AttributeType.FullName.Contains("Harmony", StringComparison.OrdinalIgnoreCase) || ca.AttributeType.FullName.Contains("Patch", StringComparison.OrdinalIgnoreCase)) {
      targetSummary.Add($"ATTR {t.FullName} [{ca.AttributeType.FullName}] {string.Join(",", ca.ConstructorArguments.Select(a=>a.Value?.ToString()))}");
    }
  }
  foreach (var m in t.Methods) foreach (var ca in m.CustomAttributes) {
    if (ca.AttributeType.FullName.Contains("Harmony", StringComparison.OrdinalIgnoreCase) || ca.AttributeType.FullName.Contains("Patch", StringComparison.OrdinalIgnoreCase)) {
      targetSummary.Add($"PATCH {t.FullName}::{m.Name} [{ca.AttributeType.FullName}] {string.Join(",", ca.ConstructorArguments.Select(a=>a.Value?.ToString()))}");
    }
  }
}
Console.WriteLine($"Unresolved count: {unresolved.Count}");
foreach (var s in unresolved.OrderBy(x=>x).Take(250)) Console.WriteLine(s);
Console.WriteLine($"Harmony/Patch attributes: {targetSummary.Count}");
foreach (var s in targetSummary.OrderBy(x=>x)) Console.WriteLine(s);
if (args.Length > 2) {
  if (unresolved.Count > 0) throw new InvalidOperationException("Cannot package an assembly with unresolved references.");
  var settings = asm.MainModule.Types.Single(t=>t.FullName=="ShieldOnly.AnimationSettings");
  var install = asm.MainModule.Types.Single(t=>t.FullName=="ShieldOnly.OptionalModSettings").Methods.Single(m=>m.Name=="Install");
  install.Body = new MethodBody(install);
  var il = install.Body.GetILProcessor();
  il.Append(il.Create(OpCodes.Newobj, settings.Methods.Single(m=>m.IsConstructor && !m.IsStatic && m.Parameters.Count==0)));
  il.Append(il.Create(OpCodes.Call, settings.Methods.Single(m=>m.Name=="set_Current")));
  il.Append(il.Create(OpCodes.Ret));
  var entry = asm.MainModule.Types.Single(t=>t.FullName=="ShieldOnly.ModEntry").Methods.Single(m=>m.Name=="Initialize");
  foreach (var ins in entry.Body.Instructions) {
    if (ins.OpCode == OpCodes.Ldstr && ins.Operand is string text && text.Contains("loaded: Ironclad"))
      ins.Operand = " loaded: standalone Android v0.111.0 port; all animations enabled; optional settings integration disabled.";
  }
  asm.Name.Version = new Version(1,9,60,1);
  Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(args[2]))!);
  asm.Write(args[2]);
  Console.WriteLine("PORT_WRITTEN="+Path.GetFullPath(args[2]));
}
Environment.ExitCode = unresolved.Count == 0 ? 0 : 1;
static IEnumerable<TypeDefinition> AllTypes(IEnumerable<TypeDefinition> ts) { foreach (var t in ts) { yield return t; foreach (var x in AllTypes(t.NestedTypes)) yield return x; } }

