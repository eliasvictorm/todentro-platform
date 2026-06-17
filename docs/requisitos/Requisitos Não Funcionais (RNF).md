**Requisitos Não Funcionais (RNF)**

**Os requisitos não funcionais descrevem como o sistema deve funcionar.**  
**Desempenho**

**RNF01:** O sistema deve responder às requisições em até 3 segundos em condições normais de uso.  
**RNF02:** O sistema deve suportar múltiplos usuários acessando simultaneamente.  
Segurança  
**RNF03:** As senhas dos usuários devem ser armazenadas de forma criptografada.  
**RNF04:** O acesso às funcionalidades protegidas deve ocorrer somente mediante autenticação JWT.  
**RNF05:** O sistema deve utilizar comunicação segura via HTTPS.  
Usabilidade  
**RNF06:** A interface deve ser intuitiva e adequada para dispositivos móveis.  
**RNF07:** O sistema deve apresentar mensagens claras de erro e sucesso.  
**RNF08:** O usuário deve conseguir acessar as principais funcionalidades com no máximo três interações.  
Compatibilidade  
**RNF09:** O aplicativo deve ser compatível com dispositivos Android e iOS.  
**RNF10:** A API deve seguir o padrão REST para integração entre frontend e backend.  
Confiabilidade  
**RNF11:** Os dados dos eventos devem ser armazenados de forma persistente no PostgreSQL.  
**RNF12:** O sistema deve manter a integridade dos dados mesmo em caso de falhas durante operações críticas.  
Manutenibilidade  
**RNF13:** O backend deve seguir arquitetura em camadas (Controller, Service e Repository).  
**RNF14:** O código deve ser documentado e versionado utilizando Git.  
**RNF15:** O sistema deve possuir testes unitários para as principais regras de negócio.  
