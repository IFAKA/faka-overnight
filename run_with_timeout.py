#!/usr/bin/env python3
import os,subprocess,sys,time,signal
hours=float(sys.argv[1]); task=sys.argv[2]; limit=int(hours*3600)
cmd=['pi','-p',f'/ralph --path {task}']
print('+',' '.join(cmd),flush=True)
p=subprocess.Popen(cmd,start_new_session=True); deadline=time.time()+limit
try:
 while True:
  rc=p.poll()
  if rc is not None: raise SystemExit(rc)
  if time.time()>=deadline:
   print('Global wall-clock limit reached',flush=True); os.killpg(p.pid,signal.SIGTERM)
   try:p.wait(timeout=20)
   except subprocess.TimeoutExpired: os.killpg(p.pid,signal.SIGKILL)
   raise SystemExit(124)
  time.sleep(2)
except KeyboardInterrupt:
 try: os.killpg(p.pid,signal.SIGINT)
 except ProcessLookupError: pass
 raise
