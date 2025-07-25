#!/bin/bash

set -e

echo "🚀 Initializing MinIO with PDF files..."

# Configure MinIO client to connect to our MinIO container
mc alias set local http://minio:9000 minioadmin minioadmin

# Wait for MinIO to be completely ready
echo "⏳ Waiting for MinIO to be ready..."
until mc admin info local > /dev/null 2>&1; do
  echo "  Still waiting for MinIO..."
  sleep 2
done
echo "✅ MinIO is ready!"

# Create the bucket
echo "📁 Creating patient-docs bucket..."
mc mb local/patient-docs --ignore-existing

echo "📤 Uploading PDF files..."

# Upload each PDF to match your database s3_key paths
# Format: mc cp /local/file.pdf minio-bucket/s3/path/file.pdf

mc cp /sample-files/tonometria_1_20230115.pdf local/patient-docs/examenes/1/20230115_tonometria_aire.pdf
echo "  ✅ Uploaded tonometria exam"

mc cp /sample-files/campovisual_1_20240210.pdf local/patient-docs/examenes/1/20240210_campo_visual_30_2.pdf
echo "  ✅ Uploaded campo visual exam"

mc cp /sample-files/topografia_2_20230308.pdf local/patient-docs/examenes/2/20230308_topografia_corneal.pdf
echo "  ✅ Uploaded topografia exam"

mc cp /sample-files/schirmer_2_20230914.pdf local/patient-docs/examenes/2/20230914_test_schirmer.pdf
echo "  ✅ Uploaded Schirmer test"

mc cp /sample-files/retino_3_20230220.pdf local/patient-docs/examenes/3/20230220_retinografia.pdf
echo "  ✅ Uploaded retinografia"

mc cp /sample-files/oct_3_20231130.pdf local/patient-docs/examenes/3/20231130_oct_macular.pdf
echo "  ✅ Uploaded OCT scan"

mc cp /sample-files/pentacam_4_20230412.pdf local/patient-docs/examenes/4/20230412_pentacam.pdf
echo "  ✅ Uploaded Pentacam"

mc cp /sample-files/biomicro_5_20240318.pdf local/patient-docs/examenes/5/20240318_biomicroscopia_anterior.pdf
echo "  ✅ Uploaded biomicroscopia"

mc cp /sample-files/retinoscopia_6_20240122.pdf local/patient-docs/examenes/6/20240122_retinoscopia.pdf
echo "  ✅ Uploaded retinoscopia"

mc cp /sample-files/adaptometria_7_20231011.pdf local/patient-docs/examenes/7/20231011_adaptometria.pdf
echo "  ✅ Uploaded adaptometria"

echo ""
echo "🎉 All files uploaded successfully!"

# Show what we uploaded
echo "📋 Files in patient-docs bucket:"
mc ls --recursive local/patient-docs/

echo ""
echo "✨ MinIO initialization complete!"
echo "🌐 Access MinIO console at: http://localhost:9001"
echo "🔑 Login: minioadmin / minioadmin"
