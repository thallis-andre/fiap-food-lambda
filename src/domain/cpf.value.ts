import { cpf as validator } from 'cpf-cnpj-validator';
import { ValidationError } from './errors/validation.error';

export class CPF {
  readonly value: string;

  constructor(cpf: string) {
    if (!validator.isValid(cpf)) {
      throw new ValidationError(`${cpf} is not a valid cpf`);
    }
    this.value = cpf.replace(/\D/g, '');
  }
}
