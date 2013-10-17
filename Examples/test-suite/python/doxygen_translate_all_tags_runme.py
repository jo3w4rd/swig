#!/usr/bin/python

import doxygen_translate_all_tags
import string
import sys
import commentVerifier


commentVerifier.check(doxygen_translate_all_tags.func01.__doc__,
r"""
  _Hello_





   -some list item

  This is attention!
  You were warned!

  Authors: lots of them
  Author: Zubr

  __boldword__

  Some brief description,
  extended to many lines.

  Not everything works right now...
  'codeword'





  'citationword'

  some test code 
  """)

commentVerifier.check(doxygen_translate_all_tags.func02.__doc__,
r"""
  Conditional comment: SOMECONDITION
  Some conditional comment
  End of conditional comment.







  Copyright: some copyright

  1970 - 2012





  Deprecated: Now use another function

  This is very large
  and detailed description of some thing
  """)

commentVerifier.check(doxygen_translate_all_tags.func03.__doc__,
r"""
  Comment for __func03()__.









  _italicword_

  emphazedWord 



  Example: someFile.txt
  Some details on using the example
  """)

commentVerifier.check(doxygen_translate_all_tags.func04.__doc__,
r"""
  Throws: SuperError



    \sqrt{(x_2-x_1)^2+(y_2-y_1)^2} 

   
      \sqrt{(x_2-x_1)^2+(y_2-y_1)^2}


   
      \sqrt{(x_2-x_1)^2+(y_2-y_1)^2}












  This will only appear in hmtl

  """)

commentVerifier.check(doxygen_translate_all_tags.func05.__doc__,
r"""
  If: ANOTHERCONDITION {
    First part of comment
    If: SECONDCONDITION {
      Nested condition text
    }Else if: THIRDCONDITION {
      The third condition text
    }Else:  {    The last text block
    }
  }Else:  {  Second part of comment
    If: CONDITION {
      Second part extended
    }
  }

  If not: SOMECONDITION {
    This is printed if not
  }

  Image: testImage.bmp("Hello, world!")











  Some text
  describing invariant.
  """)

commentVerifier.check(doxygen_translate_all_tags.func06.__doc__,
r"""
  Comment for __func06()__.




  This will only appear in LATeX




   -Some unordered list
   -With lots of items
   -lots of lots of items




  someMember Some description follows 




  This will only appear in man












  """)

commentVerifier.check(doxygen_translate_all_tags.func07.__doc__,
r"""
  Comment for __func07()__.






  Notes: Here
  is the note!

  This is an overloaded member function, provided for convenience.
  It differs from the above function only in what argument(s) it accepts.

  someword





  Title: The paragraph title
  The paragraph text.
  Maybe even multiline



  Arguments:
    a (int) -- the first param





  """)

commentVerifier.check(doxygen_translate_all_tags.func08.__doc__,
r"""
  Text after anchor.






  'Anchor description'

  'someAnchor' not quoted text is not part of ref tag

  'someAnchor'









  Remarks: Some remark text

  Another remarks section

  Return: Whatever

  it

  Returns: may return

  """)

commentVerifier.check(doxygen_translate_all_tags.func09.__doc__,
r"""
  This will only appear in RTF


  See also: someOtherMethod



  See also: function

  Same as
  brief description



  Since: version 0.0.0.1















  Throw: superException

  Throws: RuntimeError
  """)

commentVerifier.check(doxygen_translate_all_tags.func10.__doc__,
r"""
  TODO: Some very important task

  Arguments:
    b (float) -- B is mentioned again...







  very long
  text with tags <sometag>




  Version: 0.0.0.2

  Warning: This is senseless!




  This will only appear in XML


  Here goes test of symbols:
  $ @ \ & ~ < > # % " . ::

  And here goes simple text
  """)
