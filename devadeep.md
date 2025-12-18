Acknowledged. Below are the exact terminal commands, corrected to use the project name SimpleNetIDS and aligned cleanly for execution.


---

1. Navigate to the project directory

cd ~/SimpleNetIDS


---

2. Activate the Python virtual environment

source venv/bin/activate


---

3. List files (optional check)

ls -la


---

4. Capture network traffic (Terminal 1)

sudo tcpdump -i any -c 100 -w sample.pcap

While this runs:

Open YouTube / browse websites to generate traffic

Stop capture using Ctrl + C



---

5. Verify the capture file

ls -lh sample.pcap


---

6. Run the IDS script

python ids.py


---

7. Trigger port-scan traffic (Terminal 2)

nmap -p 1-100 localhost


---

8. View detected alerts

cat alerts.log


---

If you want next:

A one-slide explanation of this workflow

A README.md for submission

Or a demo narration script for viva/hackathon presentation