import { createHash } from 'crypto';
import { CPF } from './cpf.value';
import { Email } from './email.value';

export class User {
  constructor(
    readonly name: string,
    readonly role?: string,
    readonly cpf?: CPF,
    readonly email?: Email,
  ) {}

  get username() {
    return (this.cpf ?? this.email).value;
  }

  get password() {
    const hash = createHash('md5');
    hash.update(this.username);
    return hash.digest('hex');
  }
}
