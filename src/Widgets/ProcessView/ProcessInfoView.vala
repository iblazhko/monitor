public class Monitor.ProcessInfoView : Gtk.Box {
    private Process _process;
    public Process process {
        get { return _process; }
        set  {
            _process = value;
            application_name.set_text (_process.application_name);
            application_name.tooltip_text = _process.command;
            pid.set_text (("%d").printf (_process.stat.pid));
            nice.set_text (("%d").printf (_process.stat.nice));
            priority.set_text (("%d").printf (_process.stat.priority));
            username.set_text (_process.username);
            num_threads.set_text (("%d").printf (_process.stat.num_threads));
            state.set_text (_process.stat.state);

            set_icon (_process);
        }
    }
    public Gtk.Label application_name;
    public string ? icon_name;
    private Gtk.ScrolledWindow command_wrapper;
    public RoundyLabel ppid;
    public RoundyLabel pgrp;
    public RoundyLabel nice;
    public RoundyLabel priority;
    public RoundyLabel num_threads;
    public Gtk.Label state;
    public RoundyLabel username;
    public RoundyLabel pid;
    private Gtk.Image icon;
    private Regex ? regex;
    private Gtk.Grid grid;

    private Graph cpu_graph;
    private GraphModel cpu_graph_model;

    private Graph mem_graph;
    private GraphModel mem_graph_model;

    public ProcessInfoView () {
        //  get_style_context ().add_class ("process_info");
        margin = 12;
        orientation = Gtk.Orientation.VERTICAL;
        hexpand = true;
        regex = /(?i:^.*\.(xpm|png)$)/;

        var icon_container = new Gtk.Fixed ();

        icon = new Gtk.Image.from_icon_name ("application-x-executable", Gtk.IconSize.DIALOG);
        icon.set_pixel_size (64);
        icon.valign = Gtk.Align.END;

        state = new Gtk.Label (_ ("?"));
        state.halign = Gtk.Align.START;
        state.get_style_context ().add_class ("state_badge");

        icon_container.put (icon,   0,  0);
        icon_container.put (state, -5, 48);

        application_name = new Gtk.Label (_ ("N/A"));
        application_name.get_style_context ().add_class ("h2");
        application_name.ellipsize = Pango.EllipsizeMode.END;
        application_name.tooltip_text = _ ("N/A");
        application_name.halign = Gtk.Align.START;
        application_name.valign = Gtk.Align.START;



        pid = new RoundyLabel (_ ("PID"));
        nice = new RoundyLabel (_ ("NI"));
        priority = new RoundyLabel (_ ("PRI"));
        num_threads = new RoundyLabel (_ ("THR"));
        //  ppid = new RoundyLabel (_("PPID"));
        //  pgrp = new RoundyLabel (_("PGRP"));
        username = new RoundyLabel ("");

        cpu_graph_model = new GraphModel();
        cpu_graph = new Graph(cpu_graph_model);

        mem_graph_model = new GraphModel();
        mem_graph = new Graph(mem_graph_model);

        var graph_wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        graph_wrapper.valign = Gtk.Align.START;
        graph_wrapper.height_request = 60;


        graph_wrapper.add (cpu_graph);
        graph_wrapper.add (mem_graph);

        var wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        wrapper.add (pid);
        wrapper.add (priority);
        wrapper.add (nice);
        wrapper.add (num_threads);
        wrapper.add (username);

        grid = new Gtk.Grid ();
        grid.get_style_context ().add_class ("horizontal");
        grid.column_spacing = 12;
        grid.attach (icon_container,   0, 0, 1, 2);
        grid.attach (application_name, 1, 0, 3, 1);
        grid.attach (wrapper,          1, 1, 1, 1);

        add (grid);
        add (graph_wrapper);
    }

    public void update () {
        if (process != null) {
            num_threads.set_text (("%d").printf (process.stat.num_threads));
            //  ppid.set_text (("%d").printf (process.stat.ppid));
            //  pgrp.set_text (("%d").printf (process.stat.pgrp));
            state.set_text (process.stat.state);
            cpu_graph_model.update (process.cpu_usage * 100);
            cpu_graph.tooltip_text = ("%.1f%%").printf (process.cpu_usage * 100);

            mem_graph_model.update (process.mem_percentage);
            mem_graph.tooltip_text = ("%.1f%%").printf (process.mem_percentage);

            set_icon (process);
        }
    }

    private void set_icon (Process process) {
        // this construction should be somewhere else
        var icon_name = process.icon.to_string ();

        if (!regex.match (icon_name)) {
            icon.set_from_icon_name (icon_name, Gtk.IconSize.DIALOG);
        } else {
            try {
                var pixbuf = new Gdk.Pixbuf.from_file_at_size (icon_name, 64, -1);
                icon.set_from_pixbuf (pixbuf);
            } catch (Error e) {
                warning (e.message);
            }
        }
    }
}