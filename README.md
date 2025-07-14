# FIAP Food Identity - Microsserviço de Autenticação Serverless

## 📋 Descrição

Este repositório contém o código-fonte da aplicação **FiapFoodIdentity**, um microsserviço de autenticação serverless desenvolvido em TypeScript e implantado como AWS Lambda. O serviço utiliza AWS Cognito como Identity Provider (IdP) para gerenciar usuários e autenticação.

### Responsabilidades
- Cadastro de usuários (Sign Up)
- Autenticação de usuários (Sign In)
- Refresh de tokens JWT
- Integração com AWS Cognito
- Validação de CPF e email
- Gerenciamento de sessões

## 🏗️ Arquitetura

### Tecnologias Utilizadas
- **Runtime**: Node.js 20.x
- **Linguagem**: TypeScript
- **Framework**: AWS Lambda
- **Autenticação**: AWS Cognito
- **Deployment**: Serverless Framework
- **Containerização**: Docker
- **Validação**: Domain-Driven Design (DDD)

### Padrões Arquiteturais
- **Clean Architecture**
- **Domain-Driven Design (DDD)**
- **Value Objects** para CPF e Email
- **Use Cases** para lógica de negócio
- **Dependency Injection**

## 🔧 Estrutura do Projeto

```
src/
├── domain/
│   ├── cpf.value.ts              # Value Object para CPF
│   ├── email.value.ts            # Value Object para Email
│   ├── user.entity.ts            # Entidade de usuário
│   └── errors/
│       └── validation.error.ts   # Erros de domínio
├── usecases/
│   ├── abstractions/
│   │   ├── identity.service.ts   # Interface do serviço de identidade
│   │   └── usecase.ts           # Interface base de casos de uso
│   ├── sign-in.ts               # Caso de uso de login
│   └── sign-up.ts               # Caso de uso de cadastro
├── infra/
│   └── cognito-identity.service.ts # Implementação do Cognito
└── main.ts                      # Handler principal da Lambda
```

## 🔐 Casos de Uso

### 1. Sign Up (Cadastro)
```typescript
interface SignUpRequest {
  name: string;
  email: string;
  cpf: string;
  password?: string; // Opcional, gerado automaticamente se não fornecido
}

interface SignUpResponse {
  user_id: string;
  email: string;
  temporary_password?: string;
}
```

### 2. Sign In (Autenticação)
```typescript
interface SignInRequest {
  email: string;
  password: string;
}

interface SignInResponse {
  access_token: string;
  id_token: string;
  refresh_token: string;
  expires_in: number;
  token_type: string;
}
```

### 3. Refresh Token
```typescript
interface RefreshTokenRequest {
  refresh_token: string;
}

interface RefreshTokenResponse {
  access_token: string;
  id_token: string;
  expires_in: number;
  token_type: string;
}
```

## 🗄️ Integração com AWS Cognito

### Configuração do User Pool
```typescript
// Cognito User Pool Settings
const userPoolConfig = {
  UserPool: {
    UserPoolName: 'fiap-food-users',
    Policies: {
      PasswordPolicy: {
        MinimumLength: 8,
        RequireUppercase: true,
        RequireLowercase: true,
        RequireNumbers: true,
        RequireSymbols: false
      }
    },
    UsernameAttributes: ['email'],
    AutoVerifiedAttributes: ['email']
  }
};
```

### Atributos Customizados
```typescript
// Atributos adicionais do usuário
const customAttributes = [
  {
    name: 'cpf',
    attribute_data_type: 'String',
    required: true,
    mutable: false
  },
  {
    name: 'name',
    attribute_data_type: 'String',
    required: true,
    mutable: true
  }
];
```

## 🚀 Deploy e Configuração

### Pré-requisitos
- AWS CLI configurado
- Node.js 20.x
- Docker (para build local)
- Serverless Framework

### Variáveis de Ambiente
```bash
# Configurar no arquivo .env
AWS_REGION=us-east-1
COGNITO_USER_POOL_ID=<user_pool_id>
COGNITO_CLIENT_ID=<client_id>
COGNITO_CLIENT_SECRET=<client_secret>
```

### Comandos de Deploy

```bash
# Instalar dependências
npm install

# Build do projeto
npm run build

# Deploy via Serverless Framework
serverless deploy

# Ou deploy via Docker
docker build -t fiap-food-identity .
docker tag fiap-food-identity:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/fiap-food-identity:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/fiap-food-identity:latest
```

### Dockerfile
```dockerfile
FROM public.ecr.aws/lambda/nodejs:20

COPY package*.json ./
RUN npm ci --only=production

COPY dist/ ${LAMBDA_TASK_ROOT}/

CMD ["main.handler"]
```

## 📊 Monitoramento e Logs

### CloudWatch Metrics
- Invocations
- Duration
- Errors
- Throttles
- Cold starts

### Logs Estruturados
```typescript
// Exemplo de log estruturado
console.log(JSON.stringify({
  timestamp: new Date().toISOString(),
  level: 'INFO',
  message: 'User sign-in successful',
  user_id: userId,
  email: userEmail,
  request_id: context.awsRequestId
}));
```

## 🔒 Segurança

### Validações Implementadas
- ✅ Validação de CPF (algoritmo oficial)
- ✅ Validação de email (formato e domínio)
- ✅ Sanitização de inputs
- ✅ Rate limiting via API Gateway
- ✅ Criptografia de dados sensíveis

### Tratamento de Erros
```typescript
export class ValidationError extends Error {
  constructor(message: string, public field: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

// Exemplo de uso
if (!cpf.isValid()) {
  throw new ValidationError('CPF inválido', 'cpf');
}
```

## 🧪 Testes

### Estrutura de Testes
```bash
# Testes unitários
npm run test

# Testes com cobertura
npm run test:coverage

# Testes de integração
npm run test:integration
```

### Cobertura de Testes
- **Meta**: 80% de cobertura
- **Tipos**: Unitários, Integração, E2E
- **Ferramentas**: Jest, Supertest

### Exemplo de Teste
```typescript
describe('SignUpUseCase', () => {
  it('should create user successfully', async () => {
    const mockIdentityService = {
      signUp: jest.fn().mockResolvedValue({
        user_id: '123',
        email: 'test@example.com'
      })
    };

    const signUpUseCase = new SignUpUseCase(mockIdentityService);
    const result = await signUpUseCase.execute({
      name: 'Test User',
      email: 'test@example.com',
      cpf: '12345678901'
    });

    expect(result.user_id).toBe('123');
    expect(result.email).toBe('test@example.com');
  });
});
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow
```yaml
name: Deploy Lambda
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-node@v3
      with:
        node-version: '20'
    - run: npm ci
    - run: npm run test:coverage
    - run: npm run build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    - name: Deploy to Lambda
      run: |
        npm ci
        npm run build
        serverless deploy
```

## 🌐 Integração com API Gateway

### Endpoints Expostos
```
POST /auth/signup     - Cadastro de usuário
POST /auth/signin     - Autenticação
POST /auth/refresh    - Refresh token
```

### Exemplo de Uso
```bash
# Cadastro
curl -X POST https://api.fiapfood.com/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "João Silva",
    "email": "joao@example.com",
    "cpf": "12345678901"
  }'

# Login
curl -X POST https://api.fiapfood.com/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "joao@example.com",
    "password": "senhaTemporaria123"
  }'
```

## 📈 Performance

### Otimizações Implementadas
- **Cold Start**: Reduzido com provisionamento de concorrência
- **Memory**: 512MB para balance entre custo e performance
- **Timeout**: 30 segundos
- **Dead Letter Queue**: Configurada para retry de erros

### Métricas de Performance
- **Cold Start**: ~2s
- **Warm Start**: ~200ms
- **Memory Usage**: ~100MB
- **Concurrent Executions**: 100

## 📚 Documentação Adicional

### Swagger/OpenAPI
```yaml
# Documentação da API disponível em:
# https://api.fiapfood.com/docs
```

### Postman Collection
```json
{
  "info": {
    "name": "FIAP Food Identity API",
    "description": "Collection for testing identity endpoints"
  }
}
```

## 🔧 Desenvolvimento Local

### Executar Localmente
```bash
# Instalar dependências
npm install

# Executar em modo desenvolvimento
npm run dev

# Executar com Serverless Offline
serverless offline
```

### Variáveis de Desenvolvimento
```bash
# .env.local
NODE_ENV=development
AWS_REGION=us-east-1
COGNITO_USER_POOL_ID=local-pool-id
COGNITO_CLIENT_ID=local-client-id
LOG_LEVEL=debug
```

## 📚 Documentação do Projeto

Para ver a documentação completa do projeto, acesse: [FIAP Food Docs](https://github.com/thallis-andre/fiap-food-docs)

## 👨‍💻 Autor

- **Thallis André Faria Moreira** - RM360145