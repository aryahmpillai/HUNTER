# HUNTER

A lightweight but powerful automation script designed for bug bounty hunters and security researchers. It performs end to end URL discovery, parameter extraction, live host checking, and automated DAST vulnerability scanning using gau, uro, httpx, and nuclei. The script gathers archived URLs, filters only parameterized endpoints, validates which ones are live, and then scans them with Nuclei to uncover issues like SSRF, XSS, open redirects, LFI, and more. HUNTER helps you quickly identify high-value attack surfaces with minimal setup making it a practical addition to any recon workflow.     

Features
Wayback & archive URL gathering using gau
Smart URL filtering using uro
Detect only parameterized endpoints
Check live URLs using httpx
Automated vulnerability scanning using Nuclei (-dast)
Clean output files for manual testing
Fast parallel execution using xargs

Requirements


1)gau
2)uro
3)httpx
4)nuclei




Installation
git clone https://github.com/aryahmpillai/HUNTER.git
cd HUNTER
chmod +x hunter.sh


Usage
./hunter.sh example.com
./hunter.sh domain.txt


