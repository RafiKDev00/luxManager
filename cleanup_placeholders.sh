#!/bin/bash

# Check for placeholder URLs in subtasks
echo "Checking subtasks for placeholder URLs..."
curl -s 'https://nhznfazbryazoiesnzkk.supabase.co/rest/v1/subtasks?select=id,name,photo_urls' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5oem5mYXpicnlhem9pZXNuemtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzOTM5MDQsImV4cCI6MjA4MTk2OTkwNH0.RwQsKju73euoajQfeI-bG8gT4TqrStHMDl5WkUcCyRE' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5oem5mYXpicnlhem9pZXNuemtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzOTM5MDQsImV4cCI6MjA4MTk2OTkwNH0.RwQsKju73euoajQfeI-bG8gT4TqrStHMDl5WkUcCyRE' | jq '.'

echo ""
echo "Checking projects for placeholder URLs..."
curl -s 'https://nhznfazbryazoiesnzkk.supabase.co/rest/v1/projects?select=id,name,photo_urls' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5oem5mYXpicnlhem9pZXNuemtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzOTM5MDQsImV4cCI6MjA4MTk2OTkwNH0.RwQsKju73euoajQfeI-bG8gT4TqrStHMDl5WkUcCyRE' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5oem5mYXpicnlhem9pZXNuemtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzOTM5MDQsImV4cCI6MjA4MTk2OTkwNH0.RwQsKju73euoajQfeI-bG8gT4TqrStHMDl5WkUcCyRE' | jq '.'
