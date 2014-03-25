//
//  main.m
//  ormMapper
//
//  Created by Nainterceptor on 19/03/14.
//
//

#import "Pikachu.h"
#import "Attack.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        //With SQLite, DB is usually created into Documents
        NSLog(@"==================================");
        NSLog(@"CRUD Simple object with ORM : Pikachu");
        NSLog(@"==================================");

        NSLog(@"Create simple pikachu");
        NSLog(@"----------------------------------");
        Pikachu *pika = [Pikachu alloc].init;
        pika.name = @"Foo";
        pika.level = [NSNumber numberWithInt:3];
        pika.power = [NSNumber numberWithInt:10];

        NSLog(@"Persist, dump, and sleep (because threaded)");
        NSLog(@"----------------------------------");
        [pika persist];
        sleep(1);
        [pika dump];
        sleep(1);

        NSLog(@"----------------------------------");
        NSLog(@"Init object from DB for name 'Foo' and dump");
        NSLog(@"----------------------------------");
        pika = [[Pikachu alloc] initWithProperty:@"name" andValue:@"Foo"];
        [pika dump];
        sleep(1);

        NSLog(@"----------------------------------");
        NSLog(@"Increment level by 1 and power by 10");
        pika.level = [NSNumber numberWithInt:[pika.level intValue]+1];
        pika.power = [NSNumber numberWithInt:[pika.power intValue]+10];
        [pika persist];
        sleep(1);

        NSLog(@"----------------------------------");
        NSLog(@"Init object from DB for name 'Foo' and dump");
        NSLog(@"----------------------------------");
        pika = [[Pikachu alloc] initWithProperty:@"name" andValue:@"Foo"];
        [pika dump];
        sleep(1);

        NSLog(@"----------------------------------");
        NSLog(@"Remove object from DB");
        [pika remove];


        NSLog(@"==================================");
        NSLog(@"CRUD Complex object with ORM (Relational object) : Pikachu and Attacks");
        NSLog(@"==================================");

        NSLog(@"Create Complex pikachu");
        NSLog(@"----------------------------------");
        pika = [Pikachu alloc].init;
        pika.name = @"Foo";
        pika.level = [NSNumber numberWithInt:3];
        pika.power = [NSNumber numberWithInt:10];

        Attack *spark = [Attack alloc].init;
        spark.name = @"Spark";
        spark.power = [NSNumber numberWithInt:10];

        Attack *bite = [Attack alloc].init;
        bite.name = @"Bite";
        bite.power = [NSNumber numberWithInt:15];

        pika.attack = [NSMutableArray alloc].init;
        [pika.attack addObject:spark];
        [pika.attack addObject:bite];


        NSLog(@"Persist, dump, and sleep (because threaded)");
        NSLog(@"----------------------------------");
        [pika persist];
        sleep(1);
        [pika dump];
        sleep(1);

        NSLog(@"----------------------------------");
        NSLog(@"Dump Bite Attack");
        NSLog(@"----------------------------------");
        [bite dump];
        sleep(1);

        NSLog(@"----------------------------------");
        NSLog(@"Get Spark Attack from DB and dump");
        NSLog(@"----------------------------------");
        spark = [[Attack alloc] initWithProperty:@"name" andValue:@"Spark"];
        [spark dump];
        sleep(1);

        NSLog(@"----------------------------------");
        NSLog(@"Dump pokemon from spark relation (Attack array is not filled for prevent SQL loop, a solution is a lazy loading implementation)");
        NSLog(@"----------------------------------");
        [spark.pikachu dump];
        sleep(1);

        NSLog(@"----------------------------------");
        NSLog(@"If you looking for change Adapter (SQLite here), create a new adapter and change it around 'Change adapter here' comment : It's easy to change Storage engine");




    }
    return 0;
}

