import React from 'react';
import { Button, View, StyleSheet } from 'react-native';

const CustomButton = () => {
  const handlePress = () => {
    console.log('test');
  };

  return (
    <View style={styles.container}>
      <Button title="Register" onPress={handlePress} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    margin: 10,
  },
});

export default CustomButton;
