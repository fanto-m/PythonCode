
#!/usr/bin/env python3
# generate_docs.py
import ast
import os
import sys
import inspect
from pathlib import Path

def sig_from_node(node):
    params = []
    for arg in getattr(node.args, "args", []):
        params.append(arg.arg)
    # rudimentary default handling
    return "(" + ", ".join(params) + ")"

def process_file(py_path):
    with open(py_path, "r", encoding="utf-8") as f:
        src = f.read()
    try:
        tree = ast.parse(src)
    except Exception as e:
        return None, f"# Failed to parse {py_path}: {e}\n"
    md = []
    module_name = os.path.relpath(py_path)
    md.append(f"# Module `{module_name}`\n\n")
    for node in tree.body:
        if isinstance(node, ast.ClassDef):
            cls_name = node.name
            md.append(f"## Class `{cls_name}`\n\n")
            cls_doc = ast.get_docstring(node) or ""
            if cls_doc:
                md.append(f"{cls_doc}\n\n")
            for item in node.body:
                if isinstance(item, ast.FunctionDef):
                    name = item.name
                    doc = ast.get_docstring(item) or ""
                    sig = sig_from_node(item)
                    md.append(f"### `{cls_name}.{name}{sig}`\n\n")
                    md.append(doc + "\n\n" if doc else "_No docstring._\n\n")
        elif isinstance(node, ast.FunctionDef):
            name = node.name
            doc = ast.get_docstring(node) or ""
            sig = sig_from_node(node)
            md.append(f"### `{name}{sig}`\n\n")
            md.append(doc + "\n\n" if doc else "_No docstring._\n\n")
    return module_name, "\n".join(md)

def walk_and_generate(root, outdir):
    root = Path(root)
    outdir = Path(outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    for py in root.rglob("*.py"):
        if py.name.startswith("__") and py.parent.name == "__pycache__":
            continue
        mod, content = process_file(str(py))
        if mod is None:
            print(content)
            continue
        safe_name = mod.replace(os.sep, "_").replace(".", "_")
        out_file = outdir / f"{safe_name}.md"
        with open(out_file, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Wrote {out_file}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python generate_docs.py /path/to/repo output_docs")
        sys.exit(1)
    walk_and_generate(sys.argv[1], sys.argv[2])
