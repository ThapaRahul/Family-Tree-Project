
"""
@author: Rahul Thapa, Shiyu Su
"""


def makeFamilyMapTwo(familyMap, spouse1, spouse2):
    """
    this function is used when we have to put two person in our hashmap
    """
    if (spouse1 not in familyMap):
        familyMap[spouse1] = {"spouse": [],
                                "parent": [],
                                "children": []}
    if (spouse2 not in familyMap):
        familyMap[spouse2] = {"spouse": [],
                        "parent": [],
                        "children": []}
    if (spouse2 not in familyMap[spouse1]["spouse"]):
        familyMap[spouse1]["spouse"].append(spouse2)
    if (spouse1 not in familyMap[spouse2]["spouse"]):
        familyMap[spouse2]["spouse"].append(spouse1)

def makeFamilyMapThree(familyMap, spouse1, spouse2, child):
    """
    this function is used when we have to put three person in our hashmap
    """
    makeFamilyMapTwo(familyMap, spouse1, spouse2)
    
    if (child not in familyMap):
        familyMap[child] = {"spouse": [],
                            "parent": [],
                            "children": []}
    familyMap[spouse1]["children"].append(child)
    familyMap[spouse2]["children"].append(child)
    familyMap[child]["parent"].append(spouse1)
    familyMap[child]["parent"].append(spouse2)

def hasRelation(familyMap, person1, relation, cousinNum, person2):
  """
  This function is an umbrella function of various boolean relationship function.
  It takes two person and associates it with specific relationship function.
  """
  if (person1 in familyMap and person2 in familyMap):
    if (relation == "child"):
      return hasChildRelation(person1, relation, person2)
    elif (relation == "sibling"):
      return hasSiblingRelation(person1, relation, person2)
    elif (relation == "ancestor"):
      return hasAncestorRelation(person1, relation, person2)
    elif (relation == "cousin"):
      return hasCousinRelation(person1, relation, cousinNum, person2)
    elif (relation == "unrelated"):
      return isUnrelated(person1, relation, person2)
  return False

def hasChildRelation(person1, relation, person2):
  """
  returns True if person1 is children of person2
  """
  return person1 in familyMap[person2]["children"]

def hasSiblingRelation(person1, relation, person2):
  """
  returns True if person1 and person2 are siblings
  """
  parentList = familyMap[person1]["parent"]
  if (len(parentList) <=0):
    return False
  if ( person1 == person2):
    return False
  return (person2 in familyMap[parentList[0]]["children"]) or (person2 in familyMap[parentList[1]]["children"])
  

def hasAncestorRelation(person1, relation, person2):
  """
  returns True if person1 is ancestor of person 2
  """
  ancestorList = []
  ancestorList = getAncestorList(person2, ancestorList)
  return (person1 in ancestorList)
  
def hasCousinRelation(person1, relation, cousinNum, person2):
  """
  returns true of a person1 is cousin of given degree cousinNum of person2
  """
  if (person1 == person2):
    return False
  if (hasAncestorRelation(person1, relation, person2) or hasAncestorRelation(person2, relation, person1)):
    return False
  
  tempDict1 = {}
  tempDict2 = {}
  
  ancestorsWeightDict1 = getAncestorWeight(tempDict1, person1, 0)
  ancestorsWeightDict2 = getAncestorWeight(tempDict2, person2, 0)
  
  commonsDict = {}
  
  for item in ancestorsWeightDict1:
    if (item in ancestorsWeightDict2):
      commonsDict[item] = min(ancestorsWeightDict1[item], ancestorsWeightDict2[item])
      #print (commonsDict[item])

  if (len(commonsDict) > 0):
    #print(min(commonsDict.values()))
    if (min(commonsDict.values()) - 1 == int(cousinNum)):
      
      return True
    else:
      return False

def hasCommonAncestor(person1, person2):
  """
  helped function to find a common ancestor between person1 and person2
  """
  tempDict1 = {}
  tempDict2 = {}
  
  ancestorsWeightDict1 = getAncestorWeight(tempDict1, person1, 0)
  ancestorsWeightDict2 = getAncestorWeight(tempDict2, person2, 0)

  commonsDict = {}
  
  for item in ancestorsWeightDict1:
    if (item in ancestorsWeightDict2):
      commonsDict[item] = min(ancestorsWeightDict1[item], ancestorsWeightDict2[item])

  if (len(commonsDict) > 0):
    return True
  else:
    return False
    

  
def getAncestorWeight(tempDict, person, gen):
  """
  gives how many generation below a person is from his ancestor
  """
  if (person in familyMap):
    if (len(familyMap[person]["parent"]) > 0):
      tempDict[familyMap[person]["parent"][0]] = gen + 1
      tempDict[familyMap[person]["parent"][1]] = gen + 1
      getAncestorWeight(tempDict, familyMap[person]["parent"][0], gen + 1)
      getAncestorWeight(tempDict, familyMap[person]["parent"][1], gen + 1)   
  return tempDict
      

def isUnrelated(person1, relation, person2):
   """
   returns True if person1 and person2 are unrelated
   """
   if (hasAncestorRelation(person1, relation, person2) or hasAncestorRelation(person2, relation, person1)):
    return False 
  
  
   elif (hasCommonAncestor(person1,person2)):
    return False 
   else:
    return True
  
  
def relationList(familyMap, relation, cousinNum, person):
  """
  this is an umbrella function for listing person of given relationship. 
  It calls upon respective relation function based on the query
  """
  if (person not in familyMap):
    return
  
  if (relation == "child"):
    getChildList(relation, person)
  elif (relation == "sibling"):
    getSiblingList(relation, person)
  elif (relation == "ancestor"):
    ancestorList = []
    ancestorList = getAncestorList(person, ancestorList)
    ancestorList.sort()
    for item in ancestorList:
      print(item)
  elif (relation == "cousin"):
    getCousinList(relation, cousinNum, person)
  elif (relation == "unrelated"):
    getUnrelatedList(relation, person) 

def getChildList(relation, person):
  """
  returns the list of childrens of a person
  """
  children = familyMap[person]["children"]
  children.sort()
  for item in children:
    print(item)
  
def getSiblingList(relation, person):
  """
  returns the list of siblings of a person
  """
  siblings = []
  
  for item in familyMap:
    if (hasSiblingRelation(item, relation,person)):
      siblings.append(item)
  siblings.sort()
  for item in siblings:
    print(item)


def getAncestorList(person, ancestorList): 
  """
  returns list of ancestor of a person
  """ 
  parents = []
  
  if (len(familyMap[person]["parent"]) > 0 or familyMap[person]["parent"] != None):
    for item in familyMap[person]["parent"]:
      parents.append(item)
    
    for i in range(len(parents)):
      if (parents[i] not in ancestorList):
        ancestorList.append(parents[i])
        ancestorList = getAncestorList(parents[i], ancestorList)
  return ancestorList

def getCousinList(relation, cousinNum, person):
  """
  returns list of cousin of a person of certain cousin degree cousinNum
  """
  cousins = []
  
  for item in familyMap:
    if (hasCousinRelation(item, relation, cousinNum, person)):
      cousins.append(item)
  cousins.sort()
  for item in cousins:
    print(item)

def getUnrelatedList(relation, person):
  """
  returns list of all people from the family map that are unrelated to a person
  """
  unrelated = []
  
  for item in familyMap:
    if (isUnrelated(item, relation, person)):
      unrelated.append(item)
  unrelated.sort()
  for item in unrelated:
    print(item)

import sys
# fileHandle = input()
# fileHandle = open('test case 6.txt')
familyMap = {}
for line in sys.stdin:
# for line in fileHandle:
    line = line.rstrip()
    lineArr = line.split(" ")
    #print(lineArr)
    
    if lineArr[0] == "E":
        if len(lineArr) == 3:
            makeFamilyMapTwo(familyMap, lineArr[1], lineArr[2])
        elif len(lineArr) == 4:
            makeFamilyMapThree(familyMap, lineArr[1], lineArr[2], lineArr[3])
    elif lineArr[0] == "X":
        print()
        print(line)
        flag = False
        if (len(lineArr) == 4):
          if (lineArr[1] not in familyMap):
            print()
            print(lineArr[1] + " does not exist.")
            continue
          if (lineArr[3] not in familyMap):
            print()
            print(lineArr[3] + " does not exist.")
            continue
          flag = hasRelation(familyMap, lineArr[1], lineArr[2], -1, lineArr[3])
        elif (len(lineArr) == 5):
          if (lineArr[1] not in familyMap):
            print()
            print(lineArr[1] + " does not exist")
            continue
          if (lineArr[4] not in familyMap):
            print()
            print(lineArr[4] + " does not exist")
            continue
          flag = hasRelation(familyMap, lineArr[1], lineArr[2], lineArr[3], lineArr[4])
        if (flag == True):
          print("Yes")
        else:
          print("No")
    elif lineArr[0] == "W":
        print()
        print(line)
        if (len(lineArr) == 3):
          if (lineArr[2] not in familyMap):
            print()
            print(lineArr[2] + " does not exist.")
            continue
          relationList(familyMap, lineArr[1], -1, lineArr[2])
        elif (len(lineArr) == 4):
          if (lineArr[3] not in familyMap):
            print()
            print(lineArr[3] + " does not exist.")
            continue
          relationList(familyMap, lineArr[1], lineArr[2], lineArr[3])
# fileHandle.close()