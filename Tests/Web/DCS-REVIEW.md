# DCS: respostas HTMX e contrato IHttpResponse

## Implementação

O adaptador voltou a implementar o contrato atual de IHttpResponse: Status com
mensagem, SendJsonUtf8, GetOutputStream e WriteJson (valor, query e entity stream).
Os métodos seguem o adaptador WebBroker existente, com guarda de tamanho nos
callbacks de escrita. O uses duplicado de Dext.Json foi removido.

FlushToResponse recebe a intenção de preservar corpo vazio do handler, derivada
de HX-Request=true. Nesse caminho envia bytes vazios em vez de SendStatus, que
insere a descrição do status. Respostas já enviadas são preservadas.

## Testes executados

DADO o adaptador compatibilizado mas sem a correção de corpo vazio, QUANDO a
suíte HTTP real pede /empty com HX-Request=true, ENTÃO deve receber zero bytes.
RESULTADO antes: falha, recebeu `OK`. Evidência: exit 1 do teste reproduzível.

DADO o patch completo, QUANDO a suíte exercita doze rotas com e sem HTMX, ENTÃO
preserva corpo, status, JSON e HX-Redirect. RESULTADO: 24 cenários PASS, exit 0.
Inclui resposta previamente enviada, conteúdo não vazio, 204, 202, JSON por
bytes/string UTF-8/stream/TValue e WriteJson com status 201.

Dependências usadas, obtidas separadamente (não vendorizadas):

- Delphi-Cross-Socket: 7139d39cd6d351b42289787b9c73cc021d0bda39.
- CnVCL: 5876987d970500afd9a4dd91e26ef1e3afc84d88.
- Delphi 13 Win64, Dext Output Win64 Release existente.

```powershell
.\Tests\Web\Run-DcsResponseTests.ps1 -DcsRoot <clone-dcs> -CnPackRoot <clone-cnvcl> -OutputRoot <dext-output>
```

O script compila explicitamente o fonte alterado, usa DCUs isoladas e verifica
os exits. O listener fica em 127.0.0.1:9130 e é encerrado no finally.

## Segurança

- Nenhuma rota, autenticação, autorização, sessão, CORS ou configuração de produção alterada.
- Nenhum acesso a banco, segredo, credencial, dado de cliente ou dependência vendorizada.
- Teste limitado ao loopback, com timeouts HTTP; servidor encerrado ao terminar.
- O envio em TBytes usa o ownership assíncrono do CrossSocket.
- Pedidos sem HTMX preservam o contrato anterior; resposta enviada não é reenviada.

## Revisão Codex e limites

Revisão local: nenhum problema remanescente identificado no diff. Não se atribui
aprovação ao bot remoto. A suíte mede TDextDCSResponse sobre CrossSocket real;
a passagem do header no handler TDextDCSServer foi conferida no fonte. Queries
e entity streams foram compilados, mas não exercitados com banco real.
Validação Win64; Linux64 e TLS não foram executados. O compilador mantém o aviso
de licença DCS e warnings preexistentes do CnVCL, sem erros.

Decisão: APROVADO COM RESSALVAS de cobertura acima para a pendência Nexo #3471.
