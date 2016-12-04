/*
    Copyright (c) 2016 Andrey Ilskiy.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

#include "CoreData-Bridging-Header.h"

#define INTERNAL_CONCAT(a,b) a ## b
#define VERSION_NUMBER(PREFIX) INTERNAL_CONCAT(PREFIX,CoreDataVersionNumber)
#define VERSION_STRING(PREFIX) INTERNAL_CONCAT(PREFIX, CoreDataVersionString)

////! Project version number for CoreData.
extern double VERSION_NUMBER(PRODUCT_NAME_PREFIX);

////! Project version string for CoreData.
extern const unsigned char VERSION_STRING(PRODUCT_NAME_PREFIX)[];

extern double getCoreDataVersionNumber() __attribute__ ((used)) ;
extern const unsigned char* getCoreDataVersionString() __attribute__ ((used)) ;

double getCoreDataVersionNumber() {
    return VERSION_NUMBER(PRODUCT_NAME_PREFIX);
}

const unsigned char *getCoreDataVersionString() {
    return VERSION_STRING(PRODUCT_NAME_PREFIX);
}
