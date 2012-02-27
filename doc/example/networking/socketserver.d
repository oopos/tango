/*******************************************************************************

        Shows how to create a basic socket server, and how to talk to
        it from a socket client. Note that both the server and client
        are entirely simplistic, and therefore this is for illustration
        purposes only. See HttpServer for something more robust.

*******************************************************************************/

private import  tango.core.Thread;

private import  tango.io.Console;

private import  tango.net.device.Socket;

private import  tango.util.Convert;

private import  tango.io.device.File;

private import  tango.io.Stdout;

/*******************************************************************************

        Create a socket server, and have it respond to a request

*******************************************************************************/

void main()
{
        const int port = 8080;
 
        // thread body for socket-listener
        void run()
        {       
                auto server = new ServerSocket (port);
				static int no = 0;	
				while (true) {
                // wait for requests
                auto request = server.accept();

                // write a response 
				++ no;
                //request.output.write ("Hello, No." ~ to!(char[])(no) ~ " client!");
				
				char[1024] text;
				auto len = request.input.read(text);
				if (len > 1024 || len <= 0) {
					request.output.write("bad request");
					request.close;
					continue;
				}

				Stdout.formatln("{}:[{}]", len, text[0..len]);
				
				auto filename = text[0..len];

				try {
				request.output.write(cast(char[])File.get(filename));
				} catch (Exception e) {
				auto notfound = "not found " ~ filename;
				request.output.write(notfound);
				Stdout(notfound).newline;
				}
				
				request.close;

				}
        }

        // start server in a separate thread, and wait for it to start
        (new Thread (&run)).start();
        Thread.sleep (2_500_000);
		
		return;
        // make a connection request to the server
        auto request = new Socket;
        request.connect ("localhost", port);

        // wait for and display response (there is an optional timeout)
        char[64] response;
        auto len = request.input.read (response);
        Cout (response[0..len]).newline;

        request.close();
}
