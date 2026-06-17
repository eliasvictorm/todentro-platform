# **🧪✅ Plano de Teste \- (TôDentro)**

## **📋 Convenções e status**

* **🏷️ ID do teste:** RT-XX (Roteiro Manual), UT-XX (Automatizado Unitário/Integração)  
* **📌 Status:** 🟡 Planejado • 🔵 Em execução • 🟢 Passou •       🔴 Falhou • ⚫ Bloqueado  
* **⭐ Prioridade:** 🔥 Alta • ⚠️ Média • 🟦 Baixa  
* **📎 Evidência:** Print / log / vídeo / link do PR/Issue

## **🆔📖 Identificação e contexto**

| Campo | Preencher ✍️ |
| :---- | :---- |
| **🧩 Nome do projeto** | TôDentro (EventManager) |
| **📝 Objetivo do sistema (resumo)** | Plataforma de gestão de eventos casuais e rolês, automatizando o controle de lotação de vagas, geração de convites dinâmicos e divisão matemática de despesas (*split* de gastos) entre os participantes confirmados. |
| **🎯 Público-alvo** | Universitários e grupos de amigos que buscam organizar eventos sem complicações com cobranças e convites. |
| **💻 Plataforma/Tipo** | Backend: API RESTful | Frontend: Mobile |
| **🔗 Repositório** | https://github.com/eliasvictorm/todentro-platform |
| **👥 Time/Grupo** | José, Isadora, Elias, Gabriel, Carlos e Guilherme |

## 

## 

## **🎯🧪 Objetivo do teste**

| Item | Descrição 🗒️ |
| :---- | :---- |
| **✅ Objetivo geral** | Validar a integridade lógica do núcleo de negócios (Java), a segurança das fronteiras da API (Spring Security), a resiliência do aplicativo móvel contra falhas de dados (Dart Null Safety) e a usabilidade de ponta a ponta da interface do usuário. |
| **📊 Metas de cobertura** | 100% de sucesso nos testes automatizados core (mvn test e flutter test). Zero falhas críticas em fluxos de cálculo. |

## 

## **🧪🧱 Estratégia de testes (por tipo)**

| Tipo de teste | 🎯 Objetivo | 📌 Escopo | 🛠️ Ferramenta | 👤 Responsável | 📎 Saída/Evidência |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **✅ Unitário / Integração** | Validar regras de negócio, parsing de JSON e segurança de rotas. | Classes de domínio (Event, Invite), controladores e mapeadores de modelos Dart. | JUnit 5, MockMvc, flutter\_test, Mockito | José Vieira, Gabriel Andrade | Logs do Console do VS Code (PASS) e Checkmarks Verdes das IDEs. |
| **🧑‍💻 Usabilidade / Manual** | Validar comportamento visual do App. | Fluxo de login, carregamento de cards de evento, troca de tema (Dark/Light). | Emulador Android (Pixel 6 Pro \- API 33\) | José Vieira, Gabriel Andrade | Gravações de tela do emulador e prints das interfaces funcionais. |

## 

## 

## **📦📌 Escopo**

| Categoria | ✅ Em escopo | 🚫 Fora de escopo |
| :---- | :---- | :---- |
| **🧩 Funcionalidades** | Criação de eventos, controle de vagas, geração de tokens de convite, alteração de status de pagamento e listagem de feeds. | Recuperação de senhas por SMS, gateways de pagamento real (ex: API do Pix). |
| **🧠 Regras de negócio** | Divisão exata do valor do evento pelos confirmados; bloqueio de inscrição em eventos lotados; inicialização de convites como PENDING. | Penalidades financeiras ou juros por atraso no acerto de contas. |
| **🔌 Integrações** | Comunicação HTTP local entre o App Flutter e o servidor Spring Boot através de mock de rede e IP adaptativo. | Integração com mapas externos (Google Maps API) e calendários externos. |
| **🗃️ Dados** | Desserialização de payloads JSON, tratamento de arrays de datas do Jackson Mapper, injeção de *fallbacks* para campos nulos. | Migrações pesadas de banco de dados em produção (*Flyway/Liquibase*). |
| **🧑‍💻 Não-funcionais** | Usabilidade (responsividade em Dark Mode) e Segurança (bloqueio de rotas sem token JWT). | Testes de carga de estresse concorrencial simultâneo (ex: 10k requisições/s). |

## 

## 

## 

## 

## 

## 

## 

## 

## **🧰🖥️ Ambiente e ferramentas**

| Item | Especificação ⚙️ |
| :---- | :---- |
| **🖥️ SO** | Windows 11 (Ambiente de desenvolvimento com variáveis de ambiente configuradas para SDKs) |
| **☕ Linguagem/Runtime** | Backend: Java 17 (JDK) | Frontend: Dart (Flutter SDK) |
| **🧑‍💻 IDE** | VS Code / Android Studio |
| **🧱 Build** | Maven (Backend) | Flutter Build Runner (Frontend) |
| **✅ Framework testes** | JUnit 5 & MockMvc (Java) | flutter\_test & Mockito (Dart) |
| **🥒 BDD** | Não aplicável nesta etapa (foco em TDD/Unitários) |
| **🤖 CI** | Execução local automatizada via CLI pré-commit |
| **🗄️ Banco/Dados** | Banco de Dados H2 em memória (para isolamento dos testes de integração do Spring) |

## 

## 

## 

## 

## 

## **🟗🧭 Rastreabilidade (Requisitos x Testes)**

| ID Req | Requisito/Funcionalidade | ⭐ Prioridade | 🔗 Fonte | 🧪 IDs de testes | 📌 Status |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **RF-01** | Divisão e Cálculo de Despesas por participante confirmado. | 🔥 Alta |  | UT-01 (EventDomainTest) | 🟢 Executado |
| **RF-02** | Bloqueio automático de inscrições ao atingir limite de vagas. | 🔥 Alta |  | UT-02 (EventDomainTest) | 🟢 Executado |
| **RF-03** | Proteção de endpoints contra acessos sem credenciais válidas. | 🔥 Alta |  | UT-03 (EventControllerIntegrationTest) | 🟢 Executado |
| **RF-04** | Processamento de payloads com nulos e conversão de datas vindas da API. | ⚠️ Média |  | UT-04 (models\_and\_providers\_test) | 🟢 Executado |
| **RF-05** | Adaptação automatizada de IP de rede baseado em ambiente (Emulador). | ⚠️ Média |  | UT-05 (api\_service\_test) | 🟢 Executado |
| **RF-06** | Troca de temas da interface visual (Dark/Light Mode) em tempo de execução. | 🟦 Baixa |  | RT-01 (Roteiro Manual UI) | 🟢 Executado |

## **🧾🧪 Casos de teste planejados (resumo)**

| ID | 🧪 Tipo | 🏷️ Título | 🔐 Pré-condição | 📥 Entrada | ✅ Resultado esperado | ⭐ Prioridade | 🤖 Automatizado? |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| **UT-01** | ✅ Unitário | Cálculo de Split de Gastos | Evento instanciado com despesa total definida. | Adição de 4 membros confirmados. | O método de rateio deve retornar o valor total dividido exatamente por 4\. | 🔥 Alta | Sim |
| **UT-02** | ✅ Unitário | Controle de Lotação | Evento com capacidade máxima estipulada em 2 vagas. | Inserção de 3 participantes na lista. | O sistema deve aceitar os 2 primeiros e barrar o 3º lançando exceção protetora. | 🔥 Alta | Sim |
| **UT-03** | ✅ Integração | Bloqueio de Rota Protegida | Endpoint /api/events ativo e configurado no Spring Security. | Requisição HTTP GET sem cabeçalho Authorization. | Retorno HTTP Status **403 Forbidden** (Filtro interceptor ativo). | 🔥 Alta | Sim |
| **UT-04** | ✅ Unitário | Parsing de JSON Resiliente | App Flutter recebendo payloads do servidor. | String JSON com chaves essenciais com valor null e data em formato array. | Objeto instanciado no Dart aplicando valores de *fallback* padrão e data convertida para DateTime. | ⚠️ Média | Sim |
| **UT-05** | ✅ Integração | Chaveamento de IP Dinâmico | Aplicativo executando em ambiente de testes mobile. | Chamada de rede originada de emulador Android padrão. | O ApiService deve redirecionar a Base URL para o IP de loopback 10.0.2.2:8080. | ⚠️ Média | Sim |
| **RT-01** | 📝 Manual | Persistência Estética do Dark Mode | Aplicativo iniciado em qualquer uma das telas de feed do app. | Alternar a chave de tema do sistema operacional do Android de Light para Dark. | A interface deve se redesenhar instantaneamente mudando fundos para tons escuros sem quebrar legibilidade. | 🟦 Baixa | Não |

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## 

## **🗃️🧪 Dados de teste**

| ID | 🧺 Conjunto | 📝 Descrição | 🧪 Como criar | 📍 Onde armazenar | 💡 Observações |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **DT-01** | Payloads de Evento Simulado | Estruturas textuais em formato JSON imitando as saídas reais geradas pelo Jackson Mapper no Spring Boot. | Escrita manual de strings JSON estruturadas dentro do arquivo de teste do Flutter utilizando blocos de aspas triplas. | test/models\_and\_providers\_test.dart | Essencial para testar cenários onde o backend altera propriedades das entidades sem quebrar o front. |
| **DT-02** | Tokens JWT de Teste | Hashes codificados no padrão Bearer para simular sessões de usuários administradores expiradas ou válidas. | Instanciação de objetos mock de autenticação injetados diretamente no contexto do Spring Security via JUnit. | com.eventmanager.controller | Garante que a lógica de validação de criptografia não precise de conexões reais de rede para homologar a segurança. |

### **📝**

