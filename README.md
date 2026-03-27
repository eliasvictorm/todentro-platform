# 🎉 TôDentro - Organizador de Eventos Colaborativo

> Um app para organizar eventos em grupo. Centraliza criação de eventos, confirmação de participantes, votações, divisão de gastos e tarefas tudo em um só lugar.

---

## Visão

**Simplificar a organização de eventos em grupo**, eliminando a fragmentação de informações em múltiplos canais (WhatsApp, email, redes sociais). Queremos ser a plataforma única e integrada onde grupos podem gerenciar tudo: desde confirmação de presença até divisão de gastos e organização de tarefas.

---

## 📋 Sobre o Projeto

**TÔDentro** centraliza todo o planejamento de eventos em grupo em uma única plataforma. Ao invés de informações espalhadas em várias conversas, usuários podem:

- 📅 Criar e planejar eventos
- ✅ Confirmar participantes
- 🗳️ Fazer votações e enquetes
- 💰 Controlar divisão de gastos
- ✓ Organizar tarefas

O app oferece diferentes níveis de acesso - desde organizadores que gerenciam o evento até participantes e convidados - garantindo que cada um tenha as permissões necessárias para colaborar de forma organizada.

---

## 🚀 Funcionalidades Principais

✅ **Autenticação com JWT** - Login seguro e confiável  
✅ **Criar e gerenciar eventos** - Defina data, local, descrição e convide participantes  
✅ **Confirmação de presença** - Acompanhe quem confirmou presença em tempo real  
✅ **Votações e enquetes** - Faça decisões em grupo de forma colaborativa  
✅ **Divisão de gastos** - Controle automático de quem gastou e quanto cada um deve  
✅ **Histórico de pagamentos** - Rastreie pagamentos e quem já quitou a dívida  
✅ **Gerenciamento de tarefas** - Organize quem faz o quê antes e durante o evento  
✅ **Notificações em tempo real** - Receba atualizações importantes do evento  
✅ **Controle de permissões** - Cada papel tem seu nível de acesso apropriado  

---

## 🏗️ Arquitetura Mínima

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENTE (Flutter)                     │
│  - Telas (Eventos, Votações, Gastos, Tarefas)          │
│  - Estado (Provider)                                    │
│  - Comunicação via HTTP/REST                             │
└────────────────────┬────────────────────────────────────┘
                     │ API REST
                     │
┌────────────────────▼────────────────────────────────────┐
│            SERVIDOR (Java Spring Boot)                  │
│  - Controllers (requisições HTTP)                       │
│  - Services (lógica de negócio)                         │
│  - Repositories (acesso dados)                          │
│  - Security (JWT)                                       │
└────────────────────┬────────────────────────────────────┘
                     │ SQL
                     │
┌────────────────────▼────────────────────────────────────┐
│            BANCO DE DADOS (PostgreSQL)                  │
│  - Usuários, Eventos, Participantes                     │
│  - Votações, Gastos, Tarefas                           │
└─────────────────────────────────────────────────────────┘
```

**Fluxo Básico:**
1. Cliente (Flutter) faz requisição autenticada com JWT
2. Servidor (Spring Boot) valida e processa a requisição
3. Banco de dados (PostgreSQL) armazena/recupera dados
4. Servidor retorna resposta JSON ao cliente

---

## 🏗️ Tecnologias Utilizadas 

### **Backend**
- **Java 17** com **Spring Boot** - servidor da aplicação
- **PostgreSQL** - banco de dados para armazenar eventos, usuários, gastos e tarefas
- **JWT** - autenticação segura de usuários
- **API REST** - comunicação com o app mobile

### **Frontend Mobile**
- **Flutter** - aplicativo para Android e iPhone
- **Provider** - gerencia dados e estados da aplicação

---

## 👤 Papéis de Usuário

- **Organizador**: Criar e gerenciar eventos, participantes e permissões
- **Co-Organizador**: Auxiliar na gestão do evento
- **Participante**: Visualizar eventos e confirmar presença
- **Convidado**: Visualizar informações do evento e confirmar presença

---

## 📂 Estrutura de Pastas

```
a3_app/
├── backend/                    # Código do servidor (Java Spring Boot)
│   ├── src/
│   │   ├── main/java/
│   │   │   ├── controller/     # Controladores REST
│   │   │   ├── service/        # Lógica de negócio
│   │   │   ├── repository/     # Acesso ao banco de dados
│   │   │   ├── model/          # Entidades
│   │   │   └── config/         # Configurações
│   │   └── resources/
│   └── pom.xml                 # Dependências Maven
├── frontend/                   # Código do app mobile (Flutter)
│   ├── lib/
│   │   ├── screens/            # Telas da aplicação
│   │   ├── widgets/            # Componentes reutilizáveis
│   │   ├── models/             # Modelos de dados
│   │   ├── services/           # Serviços e API
│   │   ├── providers/          # Gerenciamento de estado
│   │   └── main.dart           # Entrada da aplicação
│   ├── test/                   # Testes
│   └── pubspec.yaml            # Dependências Flutter
├── docs/                       # Documentação do projeto
├── README.md                   # Este arquivo
└── projeto.txt                 # Pré-projeto
```

---

## 🚀 Como Executar o Projeto

### Pré-requisitos

**Backend:**
- Java 17 ou superior
- Maven 3.8+
- PostgreSQL 12+

**Frontend:**
- Flutter 3.0+
- Dart 3.0+
- Android Studio/Xcode (para emulador ou dispositivo)

### Executar o Backend

```bash
# 1. Navegar para a pasta do backend
cd backend/

# 2. Configurar o banco de dados em application.yml
# Editar os dados de conexão PostgreSQL se necessário

# 3. Compilar o projeto
mvn clean install

# 4. Executar a aplicação
mvn spring-boot:run

# A API estará disponível em: http://localhost:8080
```

### Executar o Frontend (Flutter)

```bash
# 1. Navegar para a pasta do frontend
cd frontend/

# 2. Instalar dependências
flutter pub get

# 3. Executar em emulador ou dispositivo
flutter run

# Ou rodar em navegador (desenvolvimento)
flutter run -d chrome
```

---

## 🧪 Como Rodar Testes

### Testes do Backend (JUnit + Mockito)

```bash
cd backend/

# Executar todos os testes
mvn test

# Executar testes de uma classe específica
mvn test -Dtest=NomeDoTest

# Gerar relatório de cobertura (JaCoCo)
mvn test jacoco:report
# Relatório disponível em: target/site/jacoco/index.html
```

### Testes do Frontend (Flutter)

```bash
cd frontend/

# Executar todos os testes unitários
flutter test

# Executar com cobertura
flutter test --coverage

# Gerar relatório de cobertura
flutter test --coverage
lcov --list coverage/lcov.info
```

---

## 📱 Telas Planejadas

1. **Tela de Login e Cadastro** - Autenticação de usuários
2. **Tela Inicial** - Dashboard com grupos e eventos
3. **Tela de Criação de Evento** - Formulário de eventos
4. **Tela de Feed do Evento** - Data, local, participantes e postagens
5. **Tela de Enquetes e Votações** - Decisões colaborativas
6. **Tela de Divisão de Gastos** - Cálculo e pagamentos
7. **Tela de Tarefas** - Checklist e organização

---

## 👥 Integrantes do Grupo

| Nome | Matrícula | Email | Papel |
|------|-----------|-------|-------|
| Carlos Nunes | 42320951 | carlitofilho695@gmail.com | Backend |
| Elias Victor de Jesus Cardoso Machado | 42415030 | elias.victor.dr@gmail.com | Frontend |
| Gabriel de Carvalho Andrade | 42521801 | gabrielcarv712@gmail.com | Frontend |
| Guilherme Ryan Costa Lana | 42412875 | Lanagui333@gmail.com | Frontend |
| Isadora Ribeiro Eugênio | 42322274 | - | QA/Backend |
| José Vieira Lopes Neto | 42413224 | jn038576@gmail.com | Backend

---

## 📄 Licença

Este projeto é parte da disciplina de **Gestão e Qualidade de Software** da Universidade UNA dentro da UC Hub.

---

## 📞 Suporte

Para dúvidas ou sugestões, abra uma issue no repositório ou entre em contato com qualquer membro do grupo.
