# Fixes for common issues during setup

##Tab doesn't work over VNC and XFCE4
Edit
~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
find the line 
\<property name="&lt;Super&gt;Tab" type="string" value="switch_window_key"/>
and change it to 
\<property name="&lt;Super&gt;Tab" type="empty"/\>

