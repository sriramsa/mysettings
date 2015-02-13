# Fixes for common issues during setup

##Tab doesn't work over VNC and XFCE4
Edit
<code>
~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
</code>
find the line 

<code>
\<property name="&lt;Super&gt;Tab" type="string" value="switch_window_key"/>
</code>

and change it to 

<code>
\<property name="&lt;Super&gt;Tab" type="empty"/\>
</code>
