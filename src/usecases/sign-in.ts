import { CPF } from '../domain/cpf.value';
import { Email } from '../domain/email.value';
import { User } from '../domain/user.entity';
import { IdentityService } from './abstractions/identity.service';
import { UseCase } from './abstractions/usecase';

type Input = {
  email?: string;
  cpf?: string;
};

type Output = {
  token: string;
};

export class SignIn implements UseCase<Input, Output> {
  constructor(private readonly identityService: IdentityService) {}

  async execute({ cpf, email }: Input): Promise<Output> {
    const emailValue = email ? new Email(email) : null;
    const cpfValue = cpf ? new CPF(cpf) : null;
    const user = new User('', null, cpfValue, emailValue);
    const token = await this.identityService.authenticate(user);
    return { token };
  }
}
