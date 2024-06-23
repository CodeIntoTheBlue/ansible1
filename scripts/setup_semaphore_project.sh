#!/bin/bash

# setup_semaphore_project.sh

# This script assumes you have jq installed and have set up the Semaphore API token

SEMAPHORE_URL="http://localhost:3000"
API_TOKEN="your-api-token-here"

# Create project
PROJECT_ID=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     -X POST \
     -d '{"name":"Infrastructure Setup","git_url":"https://your-git-repo-url.git","git_branch":"main"}' \
     "$SEMAPHORE_URL/api/projects" | jq -r '.id')

echo "Project created with ID: $PROJECT_ID"

# Create environment
ENV_ID=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     -X POST \
     -d '{"name":"Production","project_id":'$PROJECT_ID',"json":"{}"}' \
     "$SEMAPHORE_URL/api/project/$PROJECT_ID/environment" | jq -r '.id')

echo "Environment created with ID: $ENV_ID"

# Create tasks
TASKS=("Master Server Setup" "Linux Client Setup" "Windows Client Setup" "Update Configuration")
PLAYBOOKS=("master_setup.yml" "linux_client_setup.yml" "windows_client_setup.yml" "update_config.yml")

for i in "${!TASKS[@]}"; do
    TASK_ID=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
         -H "Content-Type: application/json" \
         -X POST \
         -d '{"template_id":0,"project_id":'$PROJECT_ID',"environment_id":'$ENV_ID',"playbook":"'${PLAYBOOKS[$i]}'","name":"'${TASKS[$i]}'","type":"ansible"}' \
         "$SEMAPHORE_URL/api/project/$PROJECT_ID/tasks" | jq -r '.id')
    
    echo "Task '${TASKS[$i]}' created with ID: $TASK_ID"
done

echo "Semaphore project setup complete."