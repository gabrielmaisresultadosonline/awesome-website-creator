import { z } from 'zod';

export const loginSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(6, 'A senha deve ter pelo menos 6 caracteres'),
});

export const signupSchema = loginSchema.extend({
  fullName: z.string().min(3, 'Nome muito curto'),
  whatsapp: z.string().min(10, 'WhatsApp inválido'),
  planType: z.enum(['trial', 'monthly', 'semiannual', 'annual']).optional(),
});

export type LoginValues = z.infer<typeof loginSchema>;
export type SignupValues = z.infer<typeof signupSchema>;
