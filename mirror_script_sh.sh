#############
#!/bin/bash

# Création du répertoire projet
if ! hadoop fs -test -d /user/mapr/projet &> /dev/null; then
  hadoop fs -mkdir /user/mapr/projet
  echo "Le répertoire /user/mapr/projet a été créé avec succès."
else
  echo "Le répertoire /user/mapr/projet existe déjà."
fi
# Création du répertoire data
if ! hadoop fs -test -d /user/mapr/projet/data &> /dev/null; then
  hadoop fs -mkdir /user/mapr/projet/data
  echo "Le répertoire /user/mapr/projet/data a été créé avec succès."
else
  echo "Le répertoire /user/mapr/projet/data existe déjà."
fi

# Création du volume raw-data
if ! maprcli volume info -name raw-data &> /dev/null; then
  maprcli volume create -name raw-data -path /user/mapr/projet/data/raw-data
  echo "Le volume raw-data a été créé avec succès."
else
  echo "Le volume raw-data existe déjà."
fi

# Création du répertoire clean-data
#if ! hadoop fs -test -d /user/mapr/projet/data &> /dev/null; then
#  hadoop fs -mkdir /user/mapr/projet/data
#  echo "Le répertoire /user/mapr/projet/data/clean-data a été créé avec succès."
#else
#  echo "Le répertoire /user/mapr/projet/data/clean-data existe déjà."
#fi

# Création du volume clean-data
if ! maprcli volume info -name clean-data &> /dev/null; then
  maprcli volume create -name clean-data -path /user/mapr/projet/data/clean-data
  echo "Le volume clean-data a été créé avec succès."
else
  echo "Le volume clean-data existe déjà."
fi

# Création du répertoire modeled-data
#if ! hadoop fs -test -d /user/mapr/projet/data/modeled-data &> /dev/null; then
 # hadoop fs -mkdir /user/mapr/projet/data/modeled-data
  #echo "Le répertoire /user/mapr/projet/data/modeled-data a été créé avec succès."
#else
 # echo "Le répertoire /user/mapr/projet/data/modeled-data existe déjà."
#fi

# Création du volume modeled-data
if ! maprcli volume info -name modeled-data &> /dev/null; then
  maprcli volume create -name modeled-data -path /user/mapr/projet/data/modeled-data
  echo "Le volume modeled-data a été créé avec succès."
else
  echo "Le volume modeled-data existe déjà."
fi



# Création de la planification Daily30
if ! maprcli schedule info -name Daily30 &> /dev/null; then
  maprcli schedule create -schedule '{"name":"Daily30","rules":[{"frequency":"daily","retain":"30d","time":0}]}'
  echo "La planification Daily30 a été créée avec succès."
else
  echo "La planification Daily30 existe déjà."
fi

# Création de la planification Weekly90
if ! maprcli schedule info -name Weekly90 &> /dev/null; then
  maprcli schedule create -schedule '{"name":"Weekly90","rules":[{"frequency":"weekly","retain":"90d","time":0}]}'
  echo "La planification Weekly90 a été créée avec succès."
else
  echo "La planification Weekly90 existe déjà."
fi

# Création de la planification Monthly180
if ! maprcli schedule info -name Monthly180 &> /dev/null; then
  maprcli schedule create -schedule '{"name":"Monthly180","rules":[{"frequency":"monthly","retain":"180d","time":0}]}'
  echo "La planification Monthly180 a été créée avec succès."
else
  echo "La planification Monthly180 existe déjà."
fi

# Création du snapshot raw-data-snapshot
if ! maprcli volume snapshot info -volume raw-data -snapshotname raw-data-snapshot &> /dev/null; then
  maprcli volume snapshot create -volume raw-data -snapshotname raw-data-snapshot -retain 30d
  echo "Le snapshot raw-data-snapshot a été créé avec succès."
else
  echo "Le snapshot raw-data-snapshot existe déjà."
fi

# Création du snapshot clean-data-snapshot
if ! maprcli volume snapshot info -volume clean-data -snapshotname clean-data-snapshot &> /dev/null; then
  maprcli volume snapshot create -volume clean-data -snapshotname clean-data-snapshot -retain 90d
  echo "Le snapshot clean-data-snapshot a été créé avec succès."
else
  echo "Le snapshot clean-data-snapshot existe déjà."
fi

# Création du snapshot modeled-data-snapshot
if ! maprcli volume snapshot info -volume modeled-data -snapshotname modeled-data-snapshot &> /dev/null; then
  maprcli volume snapshot create -volume modeled-data -snapshotname modeled-data-snapshot -retain 180d
  echo "Le snapshot modeled-data-snapshot a été créé avec succès."
else
  echo "Le snapshot modeled-data-snapshot existe déjà."
fi
hadoop dfs -mkdir /user/mapr/projet/mirror
# Création du volume miroir raw-data-mirror
if ! maprcli volume info -name raw-data-mirror &> /dev/null; then
  maprcli volume create -name raw-data-mirror -source raw-data@demo.mapr.com -type mirror -path /user/mapr/projet/mirror/raw-data-mirror
  maprcli volume mirror start -name raw-data-mirror
  echo "Le volume miroir raw-data-mirror a été créé avec succès et le miroir a été démarré."
else
  echo "Le volume miroir raw-data-mirror existe déjà."
fi

# Création du volume miroir clean-data-mirror
if ! maprcli volume info -name clean-data-mirror &> /dev/null; then
  maprcli volume create -name clean-data-mirror -source clean-data@demo.mapr.com -type mirror -path /user/mapr/projet/mirror/clean-data-mirror
  maprcli volume mirror start -name clean-data-mirror
  echo "Le volume miroir clean-data-mirror a été créé avec succès et le miroir a été démarré."
else
  echo "Le volume miroir clean-data-mirror existe déjà."
fi

# Création du volume miroir modeled-data-mirror
if ! maprcli volume info -name modeled-data-mirror &> /dev/null; then
 maprcli volume create -name modeled-data-mirror -source modeled-data@demo.mapr.com -type mirror -path /user/mapr/projet/mirror/modeled-data-mirror
  maprcli volume mirror start -name modeled-data-mirror
  echo "Le volume miroir modeled-data-mirror a été créé avec succès et le miroir a été démarré."
else
  echo "Le volume miroir modeled-data-mirror existe déjà."
fi


#hadoop dfs -mkdir /user/mapr/projet/mirror/raw-data-mirror-level2
#maprcli volume create -name raw-data-mirror-level2 -source raw-data-mirror@demo.mapr.com -type mirror -path /user/mapr/projet/mirror/raw-data-mirror-level2

### Creation des mirror en cascade

# Vérification et création du répertoire pour le miroir en cascade
CASCADE_DIR="/user/mapr/projet/cascade"
if ! hadoop fs -test -d "$CASCADE_DIR"; then
  hadoop fs -mkdir "$CASCADE_DIR"
  echo "Le répertoire $CASCADE_DIR a été créé avec succès."
else
  echo "Le répertoire $CASCADE_DIR existe déjà."
fi

# Vérification et création du volume data-source
if ! maprcli volume info -name data-source &> /dev/null; then
  maprcli volume create -name data-source -path "$CASCADE_DIR/data-source"
  echo "Le volume data-source a été créé avec succès."
else
  echo "Le volume data-source existe déjà."
fi

# Vérification et création du volume data-mirror-level-1
if ! maprcli volume info -name data-mirror-level-1 &> /dev/null; then
  maprcli volume create -name data-mirror-level-1 -source data-source@demo.mapr.com -type mirror -path "$CASCADE_DIR/data-mirror-level-1"
  maprcli volume mirror start -name data-mirror-level-1
  echo "Le volume data-mirror-level-1 a été créé avec succès et le miroir a été démarré."
else
  echo "Le volume data-mirror-level-1 existe déjà."
fi

# Vérification et création du volume data-mirror-level-2
if ! maprcli volume info -name data-mirror-level-2 &> /dev/null; then
  maprcli volume create -name data-mirror-level-2 -source data-mirror-level-1@demo.mapr.com -type mirror -path "$CASCADE_DIR/data-mirror-level-2"
  maprcli volume mirror start -name data-mirror-level-2
  echo "Le volume data-mirror-level-2 a été créé avec succès et le miroir a été démarré."
else
  echo "Le volume data-mirror-level-2 existe déjà."
fi

maprcli volume info -name data-mirror-level-2 –columns mirrorstatus