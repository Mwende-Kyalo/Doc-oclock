# API Configuration

## Setup Instructions

1. **Copy the template file:**
   ```bash
   cp lib/config/api_config.example.dart lib/config/api_config.dart
   ```

2. **Fill in your credentials:**
   - Open `lib/config/api_config.dart`
   - Replace all `YOUR_*_HERE` placeholders with your actual API keys and credentials

3. **Never commit `api_config.dart` to version control:**
   - The file is already in `.gitignore`
   - Only `api_config.example.dart` should be committed

## Required Credentials

### Supabase
- `supabaseUrl`: Your Supabase project URL
- `supabaseAnonKey`: Your Supabase anonymous/public key
- `supabaseSecretKey`: Your Supabase service role key (keep this secret!)

### TinyPesa (M-Pesa)
- `tinypesaUsername`: Your TinyPesa account email
- `tinypesaApiKey`: Your TinyPesa API key

### OpenAI
- `openaiApiKey`: Your OpenAI API key

### Google Calendar
- `googleClientId`: Google OAuth2 client ID

## Security Notes

⚠️ **IMPORTANT:**
- Never share your `api_config.dart` file
- Never commit it to version control
- Rotate keys immediately if they're exposed
- Use environment variables in production for better security

