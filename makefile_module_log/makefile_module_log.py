from ScrolledText import *
import sys
from logging_gui import *

if __name__ == "__main__":
  print 'Number of arguments:', len(sys.argv), 'arguments.'
  print 'Argument List:', str(sys.argv)

  print sys.argv[1]
  filenames = {}
  #logs are: HDL_log, timing_log, anchored_log, boundary_log, placement_log, logical_frame_log
  filename = sys.argv[1]+"/HDL_log"
  filenames["HDL Synthesis Log"] = filename
  filename = sys.argv[1]+"/timing_log"
  filenames["Timing Log"] = filename
  filename = sys.argv[1]+"/anchored_log"
  filenames["Anchored Log"] = filename
  filename = sys.argv[1]+"/resource_log"
  filenames["Resource Log"] = filename
  filename = sys.argv[1]+"/boundary_log"
  filenames["Boundary Log"] = filename
  filename = sys.argv[1]+"/placement_log"
  filenames["Placement Log"] = filename
  filename = sys.argv[1]+"/port_log"
  filenames["Port Log"] = filename

  for f in filenames:
    print f

  stn = LogbookGUI(filenames)
  stn.mainloop()

# END

