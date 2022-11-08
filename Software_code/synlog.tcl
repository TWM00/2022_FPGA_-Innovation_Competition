history clear
set wid1 [get_window_id]
set wid2 [open_file "D:/example_ziguang/hdmi_test _char/synthesize/synplify_impl/synplify.srs"]
win_activate $wid2
run_tcl -fg "D:/example_ziguang/hdmi_test _char/top_rtl.tcl"
project -close "D:/example_ziguang/hdmi_test _char/synthesize/synplify_impl/../synplify_pro.prj"
