[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)


# Intercom Admin Tool
- A proof of concept admin tool that adds extra functionality to Intercom

## Current Features
- Retrieve conversation transcript
  - able to show only public replies (i.e. hides notes, assignments, open, close)
  - able to email transcript to an email address using Heroku's Sparkpost addon (using the Deploy button would handle this automatically)

![](/docs/conversation_transcript.png)

## Configuration - Environment Variables
- Environment variables are needed for this webhook to work

### Required
- `APP_ID`: your app ID (or personal access token - you will need an extended token for this)
- `USERNAME`: Username for authentication
- `PASSWORD`: Password for authentication

### Optional
- `API_KEY`: your API key (blank if using a personal token)
