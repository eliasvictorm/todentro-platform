# **🧾 Plano de Roteiros de Teste Manuais (UI/UX)**

## **📋 Convenções e status**

* **Item:** Padrão ✅  
* **🏷️ ID do teste:** RT-XX (ex.: RT-01, RT-02...)  
* **📌 Status:** 🟡 Planejado • 🔵 Em execução • 🟢 Passou • 🔴 Falhou • ⚫ Bloqueado  
* **⭐ Prioridade:** 🔥 Alta • ⚠️ Média • 🟦 Baixa  
* **📎 Evidência:** Print / log / vídeo / link do PR/Issue

### **🆔 RT-01**

* **⭐ Prioridade:** 🔥 Alta  
* **🧩 Funcionalidade:** Autenticação de Usuário e Gravação de Sessão local.  
* **🎯 Objetivo:** Garantir que o aplicativo autentique o usuário na API, armazene o Token JWT com segurança no dispositivo e faça o redirecionamento automático de tela.  
* **🔐 Pré-condição:** Backend rodando (H2 ativo), banco de dados online e um usuário previamente registrado no sistema.  
* **🧪 Dados de teste:** E-mail: jose@todentro.com | Senha: senha\_segura\_123  
* **🪜 Passos:**  
  1. Abrir o aplicativo **TôDentro** no emulador Android.  
  2. Na tela de Login (login\_screen), preencher o campo de e-mail com o dado de teste.  
  3. Preencher o campo de senha corretamente.  
  4. Clicar no botão **"Entrar"**.  
* **✅ Resultado esperado:** O aplicativo deve apresentar um indicador visual de carregamento (*CircularProgressIndicator*), injetar as informações logadas no AuthProvider via *SharedPreferences*, e navegar automaticamente para a home\_screen, exibindo uma mensagem de boas-vindas com o nome do usuário.  
* **🧾 Resultado obtido:** O login foi efetuado com sucesso. O token JWT foi armazenado no banco local de preferências do app e a transição para a tela principal ocorreu sem lentidão ou engasgos visuais.  
* **📌 Status:** 🟢 Passou

### 

### 

### 

### **🆔 RT-02**

* **⭐ Prioridade:** 🔥 Alta  
* **🧩 Funcionalidade:** Atualização de Status de Pagamento de Integrantes (Split).  
* **🎯 Objetivo:** Validar se o gatilho visual de alteração de quitação de despesa atualiza o estado interno da interface e envia a requisição correta para o servidor.  
* **🔐 Pré-condição:** Usuário autenticado no app e logado como criador/organizador (owner) de um evento ativo que possua participantes da lista.  
* **🧪 Dados de teste:** ID do Evento: 100 | ID do Participante: 5 | Status Desejado: paid: true  
* **🪜 Passos:**  
  1. Na tela principal, clicar no evento gerenciado para abrir a event\_details\_screen.  
  2. Navegar até a aba/seção de gerenciamento de participantes e divisão de gastos.  
  3. Identificar o participante com status de pagamento "Pendente".  
  4. Clicar na caixinha de seleção (Checkbox) ou no botão **"Marcar como Pago"** ao lado do nome dele.  
  5. Deslizar a tela para baixo para forçar um *Pull-to-refresh* se necessário.  
* **✅ Resultado esperado:** O componente visual de checkbox deve ser marcado, o texto ou ícone do participante deve mudar para a cor verde (sinalizando "Pago") e o valor total arrecadado no cabeçalho do evento deve se recalcular em tempo de execução.  
* **🧾 Resultado obtido:** A rota PUT /api/events/100/participants/5/paid foi acionada. O backend respondeu com sucesso e o widget do Flutter atualizou o estado instantaneamente mudando a cor do indicador do participante para verde.  
* **📌 Status:** 🟢 Passou  
* **📎 Evidência:** 


### 

### 

### 

### 

### 

### **🆔 RT-03**

* **⭐ Prioridade:** ⚠️ Média  
* **🧩 Funcionalidade:** Upload e Preview de Imagem de Capa do Evento.  
* **🎯 Objetivo:** Verificar se o componente nativo de galeria do aparelho consegue resgatar um arquivo temporário de imagem e renderizá-lo como preview dentro do formulário de criação.  
* **🔐 Pré-condição:** Aplicativo aberto na tela de criação de novos eventos (create\_event\_screen).  
* **🧪 Dados de teste:** Arquivo de imagem em formato .jpeg ou .png salvo no armazenamento interno do emulador.  
* **🪜 Passos:**  
  1. No formulário de criação, clicar no contêiner pontilhado escrito **"Adicionar Foto de Capa"**.  
  2. Quando o sistema operacional abrir a janela de permissões, clicar em **"Permitir acesso à galeria"**.  
  3. Selecionar uma foto disponível na lista do dispositivo.  
* **✅ Resultado esperado:** A janela nativa de seleção deve se fechar e a imagem selecionada pelo usuário deve ser renderizada imediatamente como plano de fundo do contêiner no topo do formulário, substituindo o ícone padrão.  
* **🧾 Resultado obtido:** O pacote de imagem do Flutter capturou o caminho local do arquivo com sucesso. A renderização do preview foi imediata e o formulário manteve o estado da foto salvo na memória temporária para envio no submit.  
* **📌 Status:** 🟢 Passou  
* **📎 Evidência:**


### 

### 

### 

### 

### 

### 

### 

### 

### **🆔 RT-04**

* **⭐ Prioridade:** 🟦 Baixa  
* **🧩 Funcionalidade:** Adaptabilidade de Interface Dinâmica (Dark/Light Mode).  
* **🎯 Objetivo:** Garantir a responsividade do layout e o contraste de fontes quando o tema do sistema operacional do smartphone for alterado em tempo de execução.  
* **🔐 Pré-condição:** Aplicativo aberto em primeiro plano em qualquer tela de listagem de conteúdo.  
* **🧪 Dados de teste:** Chaveamento de configurações do sistema operacional Android.  
* **🪜 Passos:**  
  1. Com o aplicativo **TôDentro** aberto na tela inicial, arrastar a barra de notificações do emulador para baixo.  
  2. Localizar o atalho de configurações rápidas do sistema e clicar na opção **"Tema Escuro" (Dark Mode)**.  
  3. Recolher a barra de notificações e retornar imediatamente para a interface do aplicativo.  
* **✅ Resultado esperado:** O aplicativo deve interceptar a mudança de tema do SO sem a necessidade de reiniciar, redesenhando todos os fundos de tela para cores escuras (tons de preto/cinza escuro) e invertendo os textos para branco ou cinza claro, preservando 100% da legibilidade.  
* **🧾 Resultado obtido:** O Flutter aplicou as propriedades do ThemeData.dark() automaticamente. Não houve quebras de contraste de fontes secundárias e nenhum componente visual ficou ilegível.  
* **📌 Status:** 🟢 Passou  
* **📎 Evidência:** 

