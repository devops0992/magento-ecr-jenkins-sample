<?php
$time = date('Y-m-d H:i:s');
$redisStatus = 'not checked';
$dbStatus = 'not checked';

// This is a lightweight Magento-style sample page for CI/CD practice.
// Replace this public/ folder with Magento public files in your real project.
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Magento ECR Jenkins Sample</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.5; }
    .box { border: 1px solid #ddd; border-radius: 8px; padding: 20px; max-width: 760px; }
    code { background: #f5f5f5; padding: 2px 6px; border-radius: 4px; }
  </style>
</head>
<body>
  <div class="box">
    <h1>Magento Docker Compose → Jenkins → ECR</h1>
    <p>This sample app is running through <strong>Nginx + PHP-FPM</strong>.</p>
    <p>Build time test: <code><?= htmlspecialchars($time) ?></code></p>
    <p>Use this project to practice building custom Docker images and pushing them to AWS ECR from Jenkins.</p>
  </div>
</body>
</html>
