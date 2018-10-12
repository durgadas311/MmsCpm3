/* isspace  -  is the input blank ?
*/
isspace(c)
{   switch (c) {
	case ' ': case '\t': case '\n': return 1; }
    return 0;
}

