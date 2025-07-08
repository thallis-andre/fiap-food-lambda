import { User } from '../../domain/user.entity';

export interface IdentityService {
  createUser(user: User): Promise<void>;
  authenticate(user: User): Promise<string>;
}
