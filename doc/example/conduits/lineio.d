
private import  tango.io.Console,
                tango.io.device.File;

private import  tango.io.stream.Lines;

private import  tango.io.Stdout;

/*******************************************************************************

        Read a file line-by-line, sending each one to the console. This
        illustrates how to bind a conduit to a stream iterator (iterators
        also support the binding of a buffer). Note that stream iterators
        are templated for char, wchar and dchar types.

*******************************************************************************/

void main (char[][] args)
{
        if (args.length is 2)
           {
           // open a file for reading
           scope file = new File (args[1]);
		   auto num = 0;
           // process file one line at a time
           foreach (line; new Lines!(char)(file))
				{
				++ num;
                Stdout.formatln("    {} {}", num, line);
				}
           }
        else
           Cout ("usage: lineio filename").newline;
}
