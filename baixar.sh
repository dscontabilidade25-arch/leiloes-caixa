#!/usr/bin/env bash
# Baixa a lista oficial de imóveis à venda da Caixa de cada estado e publica em docs/
# Se a Caixa não responder com uma lista válida, mantém o arquivo do dia anterior.
set -u
BASE="https://venda-imoveis.caixa.gov.br/listaweb"
UFS="AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO"
mkdir -p docs
echo "{" > docs/status.tmp
echo "  \"atualizado\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> docs/status.tmp
echo "  \"estados\": {" >> docs/status.tmp
primeiro=1
for UF in $UFS; do
  tmp=$(mktemp)
  code=$(curl -sSL --max-time 90 --retry 2 --retry-delay 10 -c cookies.txt -b cookies.txt \
    -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36" \
    -H "Accept: text/csv,*/*" -H "Referer: https://venda-imoveis.caixa.gov.br/sistema/download-lista.asp" \
    -w "%{http_code}" "$BASE/Lista_imoveis_${UF}.csv" -o "$tmp" || echo 000)
  iconv -f WINDOWS-1252 -t UTF-8 "$tmp" > "$tmp.u8" 2>/dev/null || cp "$tmp" "$tmp.u8"
  if grep -qi "cidade" "$tmp.u8" && grep -qi "pre" "$tmp.u8"; then
    mv "$tmp.u8" "docs/Lista_imoveis_${UF}.csv"; ok=true
  else
    ok=false; echo "Aviso: lista de $UF não veio válida (HTTP $code, $(wc -c < "$tmp") bytes): $(head -c 160 "$tmp" | tr '\n' ' ')"
  fi
  n=$( [ -f "docs/Lista_imoveis_${UF}.csv" ] && grep -c ";" "docs/Lista_imoveis_${UF}.csv" || echo 0 )
  [ $primeiro -eq 1 ] && primeiro=0 || echo "," >> docs/status.tmp
  printf '    "%s": {"linhas": %s, "atualizada_hoje": %s}' "$UF" "$n" "$ok" >> docs/status.tmp
  rm -f "$tmp" "$tmp.u8"
  sleep 25
done
printf '\n  }\n}\n' >> docs/status.tmp
mv docs/status.tmp docs/status.json
touch docs/.nojekyll
rm -f cookies.txt
