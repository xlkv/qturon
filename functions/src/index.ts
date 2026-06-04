import * as admin from 'firebase-admin';

admin.initializeApp();

export { validatePassKey } from './auth/validate_pass_key';
