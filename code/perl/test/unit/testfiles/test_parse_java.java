/*
 * TMView.java
 * www.bouthier.net
 *
 * The MIT License :
 * -----------------
 * Copyright (c) 2001 Christophe Bouthier
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

/**
Information about this package.
*/
package treemap;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Observer;
import java.util.Observable;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;


/**
 * The TMView class implements a view of the TreeMap.
 *
 * @author Christophe Bouthier [bouthier@loria.fr]
 * @version 2.5
 */
public class TMView
    extends    JPanel
    implements Observer {

  /* --- Inners paintMethods --- */

    /**
     * The PaintMethod abstract class implements
     * a Strategie design pattern for the paintComponent method.
     */
    abstract class PaintMethod {
    
        /**
         * Paint method.
         *
         * @param g    the Graphics2D context
         */
        abstract void paint(Graphics2D g);
    }


    /**
     * The EmptyPaintMethod implements a empty paint method.
     */
    class EmptyPaintMethod
        extends PaintMethod {
    
        /**
         * Paint method.
         *
         * @param g    the Graphics2D context
         */
        final void paint(Graphics2D g) {
            revalidate();
        }
    }

    /**
     * The FullPaintMethod implements a full paint method.
     */
    class FullPaintMethod
        extends PaintMethod {
    
        /**
         * Paint method.
         *
         * @param g    the Graphics2D context
         */
        final void paint(Graphics2D g) {
            Insets insets = getInsets();
            root.getRoot().getArea().setBounds(insets.left, insets.top,
                getWidth() - insets.left - insets.right - 1,
                getHeight() - insets.top - insets.bottom - 1);
            root.getLock().lock();
            drawer.draw(g, root.getRoot());
            root.getLock().unlock();
        }
    }

}

