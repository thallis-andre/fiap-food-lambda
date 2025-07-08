import { CPF } from '../domain/cpf.value';
import { Email } from '../domain/email.value';
import { User } from '../domain/user.entity';
import { IdentityService } from './abstractions/identity.service';
import { UseCase } from './abstractions/usecase';

type Input = {
  name: string;
  email?: string;
  cpf?: string;
  role: 'CUSTOMER' | 'ADMIN' | 'APP';
};

type Output = {
  token: string;
};

export class SignUp implements UseCase<Input, Output> {
  constructor(private readonly identityService: IdentityService) {}

  async execute({ name, cpf, email, role }: Input): Promise<Output> {
    const emailValue = email ? new Email(email) : null;
    const cpfValue = cpf ? new CPF(cpf) : null;
    const user = new User(name, role, cpfValue, emailValue);
    await this.identityService.createUser(user);
    const token = await this.identityService.authenticate(user);

    return { token };
  }
}
