#!/usr/bin/env python3
from __future__ import annotations
import os,time,json,signal,subprocess,urllib.request
from pathlib import Path
from datetime import datetime,timezone
base=os.getenv('FAKA_BACKEND_URL','http://127.0.0.1:8000/v1').rstrip('/')
health=os.getenv('FAKA_BACKEND_HEALTH_URL',base+'/models')
start=os.getenv('FAKA_BACKEND_START','').strip()
interval=float(os.getenv('FAKA_BACKEND_CHECK_INTERVAL','20')); threshold=int(os.getenv('FAKA_BACKEND_FAILURES_TO_RESTART','3')); startup=float(os.getenv('FAKA_BACKEND_STARTUP_TIMEOUT','180'))
logp=Path(os.getenv('FAKA_WATCHDOG_LOG','.faka/watchdog.jsonl')); logp.parent.mkdir(parents=True,exist_ok=True)
stopping=False; child=None
def log(event,**kw):
 row={'ts':datetime.now(timezone.utc).isoformat(),'event':event,**kw}; s=json.dumps(row); print('[watchdog]',s,flush=True)
 with logp.open('a') as f: f.write(s+'\n')
def ok():
 try:
  with urllib.request.urlopen(urllib.request.Request(health,headers={'Accept':'application/json'}),timeout=8) as r: return 200<=r.status<500
 except Exception:return False
def launch():
 global child
 if not start: log('restart_skipped',reason='FAKA_BACKEND_START unset'); return
 log('backend_start',command=start)
 child=subprocess.Popen(start,shell=True,executable='/bin/bash',start_new_session=True,stdout=open('.faka/backend.stdout.log','ab'),stderr=open('.faka/backend.stderr.log','ab'))
 deadline=time.time()+startup
 while time.time()<deadline and not stopping:
  if ok(): log('backend_healthy_after_start',pid=child.pid); return
  if child.poll() is not None: log('backend_exited_during_start',code=child.returncode); return
  time.sleep(3)
 log('backend_start_timeout')
def stop(*_):
 global stopping; stopping=True
signal.signal(signal.SIGTERM,stop); signal.signal(signal.SIGINT,stop)
log('watchdog_started',health_url=health,restart_enabled=bool(start)); failures=0
while not stopping:
 if ok():
  if failures: log('backend_recovered',previous_failures=failures)
  failures=0
 else:
  failures+=1; log('health_failure',consecutive=failures)
  if failures>=threshold: launch(); failures=0
 end=time.time()+interval
 while time.time()<end and not stopping: time.sleep(.5)
log('watchdog_stopped')
