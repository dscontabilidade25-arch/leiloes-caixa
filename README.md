# Listas de imóveis da Caixa · DS Contabilidade

Listas oficiais de imóveis à venda da Caixa, usadas pelo botão **Atualizar lista da Caixa** do Simulador GCAP Leilão.

A Caixa protege o download com captcha, então as listas são baixadas por uma pessoa, no navegador, e enviadas para cá. O robô deste projeto **não acessa o site da Caixa**: ele só organiza os arquivos enviados.

## Estados prioritários

Atualize primeiro os estados onde os alunos mais arrematam:

1. **SP** – São Paulo (maior volume do país)
2. **RJ** – Rio de Janeiro
3. **MG** – Minas Gerais
4. **BA** – Bahia

Outros estados podem ser enviados quando necessário; o simulador aceita os 27.

## Como atualizar (1x por semana)

1. No site de imóveis da Caixa, baixe a lista de cada estado prioritário (arquivo `Lista_imoveis_UF.csv`), resolvendo o captcha normalmente.
2. Aqui no GitHub, abra a pasta **docs** > **Add file** > **Upload files**, arraste os arquivos e clique em **Commit changes**.
3. Em cerca de 1 minuto o robô padroniza os arquivos e atualiza o `status.json`. Os alunos já recebem a lista nova.

> Todo domingo você recebe um lembrete automático para fazer essa atualização.
