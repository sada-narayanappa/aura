mvn install -DskipTests=true -Dlicense.skip=true -Dpmd.skip
sleep 5
reload.sh
echo "All Done ..."
