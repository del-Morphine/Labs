#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int** create_matrix(int n, int m);
void rand_matrix(int **matr, int n, int m);
void print_matrix(int **matr, int n, int m);
void free_matrix(int **matr, int n, int m);
void cut_matrix (int **matr, int n, int m);
 
int main()
{
    int n = 0;
    int m = 0;
   
    printf("Матрица NxM: ");
    scanf("%d", &n);
    scanf("%d", &m);
 
    int **matr = create_matrix(n, m);
    rand_matrix(matr, n, m);
    print_matrix(matr, n, m);
    cut_matrix(matr, n, m);
    free_matrix(matr, n, m);
 
    return 0;
} 
 
 
int** create_matrix(int n, int m)
{
    int **matr = calloc(n, sizeof(int*));   // первое измерение
    if (matr == NULL)
        perror("Ошибка выделения памяти\n");
   
    for (int i = 0; i < n; i++)
    {
        matr[i] = calloc(m, sizeof(int));   // второе измерение
        if (matr[i] == NULL)
            perror("Ошибка выделения памяти\n");
    }

    return matr;
}
 
void rand_matrix(int **matr, int n, int m)
{  
 srand(time(NULL));
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            matr[i][j] =-30 + rand() %60;
        }
    }
}
 
void print_matrix(int **matr, int n, int m)
{
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            printf("%3d ", matr[i][j]);
        }
    puts("");
    }
}
 
void free_matrix(int **matr, int n, int m)
{
    for(int i = 0; i < n; ++i)
        free(matr[i]);
    free(matr);
}
 
void cut_matrix(int **matr, int n, int m)
{
    // максимум, минимум и их индексы
    int max = matr[0][0];
    int max_i = 0;
    int max_j = 0;
    int min = matr[0][0];
    int min_i = 0;
    int min_j = 0;
 
    // поиск макисмума и минимума
    for (int i = 0; i < n; i++)        // пробежка по "строкам"
    {
        for (int j = 0; j < m; j++)    // пробежка по "столбцам"
        {   
            if (max < matr[i][j])
            {
                max = matr[i][j];
                max_i = i;
                max_j = j;
            }
            if (min > matr[i][j])
            {
                min = matr[i][j];
                min_i = i;
                min_j = j;
            }
        }
    }
   
    printf("\nmin = %d\nmax = %d\n\n", min, max);
 
    int amount_str;
    int amount_clm;
    int count_i;
    int count_j;
    amount_str = max_i - min_i;
    if(amount_str < 0)
        amount_str *= -1;               //Когда min_i правее, чем max_i

    amount_clm = max_j - min_j;
    if(amount_clm < 0)
        amount_clm *= -1;

    if(max_i < min_i)
        count_i = max_i;
    else
        count_i = min_i;
       
    if(max_j < min_j)
        count_j = max_j;
    else
        count_j = min_j;
       
     
    for (int i = count_i; i <= count_i + amount_str; i++) //откуда; границы (столбцы), i++
    {
        for (int j = count_j; j <= count_j + amount_clm; j++) //откуда; границы(строки), j++
        {
            printf("%3d", matr[i][j]);
        }
        puts("");
    }
    puts("");
}