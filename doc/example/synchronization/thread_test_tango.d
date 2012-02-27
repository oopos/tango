import tango.io.Stdout;
import tango.core.Thread;
import tango.core.sync.Mutex;


void main()
{

	__gshared Mutex gMutex;
	
	gMutex = new Mutex();
	int id = 0;
	void run()
	{
		synchronized(gMutex) {
		id ++;
		Stdout.formatln("thread {} is running.", id);
		}
	}


	class ThreadTest : Thread {
		this(int t)
		{
			synchronized(gMutex) {
			Stdout.formatln("thread {} init...", id);
			}
			super(&run);
		}
	}


    Thread t1 = new ThreadTest(1);
    Thread t2 = new ThreadTest(2);

    t1.start();
    t2.start();
}

