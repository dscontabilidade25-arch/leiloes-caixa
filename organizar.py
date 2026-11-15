"""Organiza as listas da Caixa enviadas manualmente para docs/.
Não acessa o site da Caixa: só padroniza os arquivos que a DS Contabilidade baixou no navegador."""
import json, pathlib, re, datetime
d = pathlib.Path("docs")
status = {"atualizado": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"), "estados": {}}
for f in sorted(d.glob("*.[cC][sS][vV]")):
    raw = f.read_bytes()
    try:
        txt = raw.decode("utf-8")
    except UnicodeDecodeError:
        txt = raw.decode("cp1252")
    linhas = [l for l in txt.splitlines() if l.strip()]
    uf = None
    for l in linhas[2:12]:
        c = l.split(";")
        if len(c) > 2 and re.fullmatch(r"[A-Z]{2}", c[1].strip()):
            uf = c[1].strip(); break
    m = re.search(r"Lista_imoveis_([A-Za-z]{2})", f.name)
    uf = uf or (m.group(1).upper() if m else None)
    if not uf:
        print("Arquivo sem UF reconhecida:", f.name); continue
    destino = d / f"Lista_imoveis_{uf}.csv"
    destino.write_text(txt, encoding="utf-8")
    if f != destino:
        f.unlink()
    gerado = re.search(r"(\d{2}/\d{2}/\d{4})", linhas[0]) if linhas else None
    status["estados"][uf] = {"imoveis": max(0, len(linhas) - 2), "data_da_lista": gerado.group(1) if gerado else ""}
(d / "status.json").write_text(json.dumps(status, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps(status, ensure_ascii=False))
