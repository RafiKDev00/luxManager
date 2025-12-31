#!/bin/bash

# Create a tiny test image (1x1 red pixel JPG)
echo -n "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAABAAEDAREAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwA/wA=" | base64 -d > test.jpg

# Try to upload to Supabase Storage
echo "Testing upload to Supabase Storage..."
curl -X POST "https://nhznfazbryazoiesnzkk.supabase.co/storage/v1/object/photos/test-$(date +%s).jpg" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5oem5mYXpicnlhem9pZXNuemtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzOTM5MDQsImV4cCI6MjA4MTk2OTkwNH0.RwQsKju73euoajQfeI-bG8gT4TqrStHMDl5WkUcCyRE" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5oem5mYXpicnlhem9pZXNuemtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzOTM5MDQsImV4cCI6MjA4MTk2OTkwNH0.RwQsKju73euoajQfeI-bG8gT4TqrStHMDl5WkUcCyRE" \
  -H "Content-Type: image/jpeg" \
  --data-binary @test.jpg \
  -w "\nHTTP Status: %{http_code}\n"

rm test.jpg
