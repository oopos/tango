/*
 File: BinaryFunction.d

 Originally written by Doug Lea and released into the public domain. 
 Thanks for the assistance and support of Sun Microsystems Labs, Agorics 
 Inc, Loral, and everyone contributing, testing, and using this code.

 History:
 Date     Who                What
 22Oct95  dl@cs.oswego.edu   Created.
 9Apr97   dl                 made Serializable
*/


module tango.store.model.BinaryFunction;

/**
 *
 * BinaryFunction is a common interface for classes with an arbitrary 
 * function of two Object arguments that returns an Object result,
 * without throwing any kind of user exception.
 * 
        author: Doug Lea
 * @version 0.93
 *
 * <P> For an introduction to this package see <A HREF="index.html"> Overview </A>.
 *
**/

public interface BinaryFunctionT(T)
{

        /**
         * Execute some function of two arguments. return a result
        **/

        public T binaryFunction(T fst, T snd);
}

alias BinaryFunctionT!(Object) BinaryFunction;