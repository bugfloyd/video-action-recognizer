export interface CreateUserRequest {
  given_name: string;
  family_name?: string;
  email: string;
}

export interface UpdateUserRequest {
  given_name?: string;
  family_name?: string;
  email?: string;
}

export interface APIUser {
  username?: string;
  email: string;
  given_name: string;
  family_name: string;
  created_at?: Date;
  modified_at?: Date;
}