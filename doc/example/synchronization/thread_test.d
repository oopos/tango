import std.stdio;
import core.thread;

class ThreadTest : Thread {
    this(int id)
    {
        this.id = id;
        writefln("thread %d init...", this.id);
        super(&run);
    }

	void run()
    {
        writefln("thread %d is running.", this.id);
    }

    int id;
}


void main()
{
    Thread t1 = new ThreadTest(1);
    Thread t2 = new ThreadTest(2);

    t1.start();
    t2.start();
}


