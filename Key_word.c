#include <stdio.h>
#include <string.h>
#include <malloc.h>

#define RANGE 20    //Диапазон контекста
 
int find(FILE *f, char *flag);
int fsize(FILE *f);
int countFileRest(FILE *f, int cur_pos);

int main(int argc, char * argv[])
{
  if(argc != 3)
  {
    printf("%s\n", "ff");
    return 1;
  }

  FILE *f = fopen(argv[1], "r");
  find(f, argv[2]);

  return 0;
}


int find(FILE *f, char *flag)
{
  int chr = 0;
  int len = strlen(flag);
  int pos = 0;
  char *cmp_word = (char*) malloc(len);
  int context;

  while(fgetc(f) != EOF)
  {
    fseek(f, -1, SEEK_CUR);
    for(int i = 0; i < len; ++i)
      cmp_word[i] = fgetc(f);

    if(!strcmp(cmp_word, flag))
    {
      context = ftell(f);                         //Сколько символов слева до искомого слова
      if(context > RANGE) {context = RANGE;}      //Если больше RANGE, урезаем
      fseek(f, -len -context, SEEK_CUR);

      for(int i = 0; i < context; ++i)            //Вывод контекста слева
        printf("%c", fgetc(f));
      
      //Вывод слова (cmp_word == flag)
      printf("%s", cmp_word);

    
      context = countFileRest(f, ftell(f));       //Сколько символов справа после искомого слова 
      if(context > RANGE) {context = RANGE;}      //Если больше RANGE, урезаем
      fseek(f, len, SEEK_CUR);

      for(int i = 0; i < context; ++i)
        printf("%c", fgetc(f));


      printf("\n\n");
    }
    ++pos;                                        //+1 Прямой поиск образца в тексте
    fseek(f, pos, SEEK_SET);
  }

  return 0;
}


int fsize(FILE *f)
{

  if(!f)
  {
    return 1;
  }

  int savePos = ftell(f);
  fseek(f, 0, SEEK_END);
  int size = ftell(f);
  fseek(f, 0, SEEK_SET);
  fseek(f, savePos, SEEK_SET);

  return size;
}


int countFileRest(FILE *f, int cur_pos)
{
  return fsize(f) - cur_pos;
}