/*******************************************************************************

        Shows how to create a basic socket client, and how to converse with
        a remote server. The server must be running for this to succeed

*******************************************************************************/

private import  tango.io.Console;

private import  tango.net.device.Socket, 
                tango.net.InternetAddress;

private import  tango.io.Stdout;

void main(char[][] args)
{
		if (args.length < 2) {
			Stdout.formatln("Usage: {} [filename]", args[0]);
			return;
		}
        // make a connection request to the server
        auto request = new Socket;
        request.connect (new InternetAddress ("localhost", 8080));
		Cout(args[1]).newline;
        request.output.write (args[1]);

        // wait for response (there is an optional timeout supported)
		auto total = 0;
		Stdout("[").newline;
		while (true) {
        char[64] response;
        auto size = request.input.read (response);
		if (size <= 0 || size > response.length) {
			break;
		}
		total += size;
		Stdout(response[0..size]);
		}
		Stdout.formatln("],{}", total).newline;

        // close socket
        request.close();
}
